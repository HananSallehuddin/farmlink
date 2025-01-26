import 'package:farmlink/bottomNaviBarSeller.dart';
import 'package:farmlink/controllers/AnalyticController.dart';
import 'package:farmlink/styles.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

class analyticUI extends StatefulWidget {
  @override
  _AnalyticUIState createState() => _AnalyticUIState();
}

class _AnalyticUIState extends State<analyticUI> {
  final AnalyticController analyticController = Get.put(AnalyticController());

  // Reactive selectedMonth
  RxString selectedMonth = 'Jan'.obs;

  @override
  void initState() {
    super.initState();
    // Ensure fetching of sales data occurs after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndFetchSalesData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sales Analytics')),
      body: SingleChildScrollView(
        child: Center(
          child: Obx(() {
            // Show loading spinner while data is loading
            if (analyticController.orderedProducts.isEmpty || analyticController.monthlySales.isEmpty) {
              return CircularProgressIndicator();
            } else {
              // Display analytics UI after data is loaded
              return Column(
                children: [
                  SizedBox(height: 20),
                  // Month Selector
                  _buildMonthSelector(),
                  SizedBox(height: 20),
                  // Bar Chart for the selected month
                  _buildBarChart(selectedMonth.value),
                  SizedBox(height: 50),
                  // Display ordered products with quantities
                  Text(
                    'Product Sold:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  _buildOrderedProductsTable(),
                ],
              );
            }
          }),
        ),
      ),
      bottomNavigationBar: bottomNavigationBarSeller(
        currentRoute: '/analytic',
      ),
    );
  }

  /// Checks and fetches sales data (dummy or real)
  void _checkAndFetchSalesData() {
    String currentUserUid = FirebaseAuth.instance.currentUser!.uid;
    analyticController.fetchSalesData();  // Assuming this method checks the sales data.
    // If you need to populate dummy data, you can do so here as well
    if (currentUserUid == analyticController.hardcodedSellerId) {
      analyticController.populateDummyDataForChart();  // Populate dummy data if needed
    }
  }

  /// Month Selector (Dropdown Menu)
  Widget _buildMonthSelector() {
    List<String> months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return DropdownButton<String>(
      value: selectedMonth.value, // Reactive value
      onChanged: (newMonth) {
        selectedMonth.value = newMonth!; // Update reactive value
      },
      items: months.map<DropdownMenuItem<String>>((String month) {
        return DropdownMenuItem<String>(
          value: month,
          child: Text(month),
        );
      }).toList(),
    );
  }

  /// Bar Chart for the selected month
  Widget _buildBarChart(String month) {
    return Container(
      height: 400,
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.center,
          barGroups: _showingSalesForMonth(analyticController.monthlySales, month),
          titlesData: _buildTitlesData(),
          borderData: FlBorderData(show: false),
          gridData: FlGridData(show: true, drawVerticalLine: true, drawHorizontalLine: false),
        ),
      ),
    );
  }

  /// Sales data for a particular month
  List<BarChartGroupData> _showingSalesForMonth(
      Map<String, Map<String, double>> monthlySales, String selectedMonth) {
    List<BarChartGroupData> barGroups = [];
    Map<String, double> categorySales = monthlySales[selectedMonth] ?? {};

    List<Color> categoryColors = [
      Colors.red, // Fruits
      Colors.green, // Vegetables
      Colors.purple, // Herbs
      Colors.blue, // Others
    ];

    int index = 0;
    categorySales.forEach((category, sales) {
      barGroups.add(
        BarChartGroupData(
          x: index++,
          barRods: [
            BarChartRodData(
              y: sales,
              colors: [categoryColors[_categoryToIndex(category)]],
              width: 15,
              backDrawRodData: BackgroundBarChartRodData(show: false),
            ),
          ],
        ),
      );
    });

    return barGroups;
  }

  /// Title formatting for the chart (X-axis)
  FlTitlesData _buildTitlesData() {
    return FlTitlesData(
      leftTitles: SideTitles(
        showTitles: true,
        getTitles: (value) => value.toInt() % 100 == 0 ? value.toInt().toString() : '',
        interval: 300,
        margin: 8,
      ),
      bottomTitles: SideTitles(
        showTitles: true,
        getTitles: (double value) {
          if (value.toInt() < categories.length) {
            return categories[value.toInt()];
          }
          return '';
        },
        margin: 16,
        rotateAngle: 45,
      ),
    );
  }

  List<String> categories = ['Fruits', 'Vegetables', 'Herbs', 'Others'];

  /// Convert category to index for colors
  int _categoryToIndex(String category) {
    return categories.indexOf(category);
  }

  /// Display ordered products in a table
  Widget _buildOrderedProductsTable() {
    return Table(
      border: TableBorder.all(color: Colors.black),
      columnWidths: {
        0: FixedColumnWidth(150),
        1: FixedColumnWidth(100),
      },
      children: [
        // Header Row
        TableRow(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Product Name',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Quantity',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        // Data Rows
        ...analyticController.orderedProducts.entries.map((entry) {
          var productName = entry.key;
          var quantity = entry.value;
          return TableRow(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(productName),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(quantity.toString()),
              ),
            ],
          );
        }).toList(),
      ],
    );
  }
}