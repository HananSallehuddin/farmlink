import 'package:farmlink/bottomNaviBarSeller.dart';
import 'package:farmlink/controllers/AnalyticController.dart';
import 'package:farmlink/styles.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class analyticUI extends StatelessWidget {
  final AnalyticController analyticController = Get.put(AnalyticController());

  @override
  Widget build(BuildContext context) {
    // Data is already fetched onInit of the controller
    return Scaffold(
      appBar: AppBar(title: Text('Sales Analytics')),
      body: SingleChildScrollView(
        child: Center(
          child: Obx(() {
            if (analyticController.monthlySales.isEmpty) {
              return Text(
                'No sales data available',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              );
            } else {
              return Column(
                children: [
                  SizedBox(height: 20),
                  _buildBarChart(),
                  SizedBox(height: 20),
                  _buildTotalSalesText(),
                  SizedBox(height: 20),
                  _buildMostSoldProduceText(),
                ],
              );
            }
          }),
        ),
      ),
      bottomNavigationBar: bottomNavigationBarSeller(currentRoute: '/analytic'),
    );
  }

  Widget _buildBarChart() {
    return Container(
      height: 400,
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          barGroups: _showingMonthlySales(analyticController.monthlySales),
          titlesData: _buildTitlesData(),
          barTouchData: _buildBarTouchData(),
          borderData: FlBorderData(show: false),
          gridData: FlGridData(show: true, drawVerticalLine: true),
        ),
      ),
    );
  }

  FlTitlesData _buildTitlesData() {
    return FlTitlesData(
      leftTitles: SideTitles(
        showTitles: true,
        getTitles: (value) => value.toInt() % 100 == 0 ? value.toInt().toString() : '',
        interval: 100,
        margin: 8,
      ),
      bottomTitles: SideTitles(
        showTitles: true,
        getTitles: (double value) {
          return _monthFromIndex(value.toInt());
        },
        margin: 16,
      ),
    );
  }

  BarTouchData _buildBarTouchData() {
    return BarTouchData(
      touchTooltipData: BarTouchTooltipData(
        tooltipBgColor: Colors.blueAccent,
        getTooltipItem: (group, groupIndex, rod, rodIndex) {
          String month = _monthFromIndex(group.x.toInt());
          return BarTooltipItem(
            '$month\nRM${rod.y.toStringAsFixed(2)}',
            TextStyle(color: Colors.white),
          );
        },
      ),
    );
  }

  Widget _buildTotalSalesText() {
    double totalSales = analyticController.monthlySales.values.fold(0.0, (sum, element) => sum + element);
    return Text(
      'Total Sales: RM${totalSales.toStringAsFixed(2)}',
      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildMostSoldProduceText() {
    return Text(
      'Most Sold Produce: ${analyticController.mostSoldProduce.value}',
      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  List<BarChartGroupData> _showingMonthlySales(Map<String, double> monthlySales) {
    List<BarChartGroupData> barGroups = [];
    monthlySales.forEach((month, sales) {
      int index = _monthToIndex(month);
      barGroups.add(
        BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              y: sales,
              colors: [Styles.primaryColor],
              width: 15,
              backDrawRodData: BackgroundBarChartRodData(show: false),
            ),
          ],
        ),
      );
    });
    return barGroups;
  }

  int _monthToIndex(String month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months.indexOf(month);
  }

  String _monthFromIndex(int index) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return index >= 0 && index < months.length ? months[index] : '';
  }
}