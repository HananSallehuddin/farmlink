import 'package:farmlink/bottomNaviBarSeller.dart';
import 'package:farmlink/controllers/analyticController.dart';
import 'package:farmlink/styles.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class analyticUI extends StatelessWidget {
  final AnalyticController analyticController = Get.put(AnalyticController());

  @override
  Widget build(BuildContext context) {
    analyticController.fetchMonthlySales();
    analyticController.fetchTotalSales(); // Ensure the total sales are fetched

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
                  Container(
                    height: 400,
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        barGroups: _showingMonthlySales(analyticController.monthlySales),
                        titlesData: FlTitlesData(
                          leftTitles: SideTitles(
                            showTitles: true,
                            getTitles: (value) {
                              return (value.toInt() % 100 == 0) ? value.toInt().toString() : '';
                            },
                            interval: 100,
                            margin: 8,
                          ),
                          bottomTitles: SideTitles(
                            showTitles: true,
                            getTitles: (double value) {
                              switch (value.toInt()) {
                                case 0:
                                  return 'Jan';
                                case 1:
                                  return 'Feb';
                                case 2:
                                  return 'Mar';
                                case 3:
                                  return 'Apr';
                                case 4:
                                  return 'May';
                                case 5:
                                  return 'Jun';
                                case 6:
                                  return 'Jul';
                                case 7:
                                  return 'Aug';
                                case 8:
                                  return 'Sep';
                                case 9:
                                  return 'Oct';
                                case 10:
                                  return 'Nov';
                                case 11:
                                  return 'Dec';
                                default:
                                  return '';
                              }
                            },
                            margin: 16,
                          ),
                        ),
                        barTouchData: BarTouchData(
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
                        ),
                        borderData: FlBorderData(show: false),
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: true,
                          drawHorizontalLine: false,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Total Sales: RM${analyticController.totalSales.value.toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  // Display most sold produce
                  analyticController.mostSoldProduce.value != 'No produce sold'
                      ? Text(
                          'Most Sold Produce: ${analyticController.mostSoldProduce.value}',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        )
                      : Text(
                          'No produce sold this month',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                ],
              );
            }
          }),
        ),
      ),
      bottomNavigationBar: bottomNavigationBarSeller(currentRoute: '/analytic')
    );
  }

  List<BarChartGroupData> _showingMonthlySales(Map<String, double> monthlySales) {
    List<BarChartGroupData> barGroups = [];
    monthlySales.forEach((month, sales) {
      sales = sales.isFinite ? sales : 0.0;
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
    switch (month) {
      case 'Jan': return 0;
      case 'Feb': return 1;
      case 'Mar': return 2;
      case 'Apr': return 3;
      case 'May': return 4;
      case 'Jun': return 5;
      case 'Jul': return 6;
      case 'Aug': return 7;
      case 'Sep': return 8;
      case 'Oct': return 9;
      case 'Nov': return 10;
      case 'Dec': return 11;
      default: return 0;
    }
  }

  String _monthFromIndex(int index) {
    switch (index) {
      case 0: return 'Jan';
      case 1: return 'Feb';
      case 2: return 'Mar';
      case 3: return 'Apr';
      case 4: return 'May';
      case 5: return 'Jun';
      case 6: return 'Jul';
      case 7: return 'Aug';
      case 8: return 'Sep';
      case 9: return 'Oct';
      case 10: return 'Nov';
      case 11: return 'Dec';
      default: return '';
    }
  }
}