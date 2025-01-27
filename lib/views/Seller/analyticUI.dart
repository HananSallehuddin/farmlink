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
            
            if (analyticController.monthlySales.isEmpty) {
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
                  _buildTotalSales(selectedMonth.value),
                  SizedBox(height: 50),
                  // Display total sales for the year
                  _buildYearlyBarChart(),
                  SizedBox(height: 50),
                  Text(
                  'Total Sales for the Year: \RM${_calculateTotalSalesForYear(analyticController.monthlySales).toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
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
    analyticController.fetchSalesData(); 
    analyticController.fetchOrderedProducts();
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

  /// Display Total Sales for the selected month
  Widget _buildTotalSales(String month) {
    double totalSales = 0.0;
    Map<String, double> categorySales = analyticController.monthlySales[month] ?? {};
    categorySales.forEach((category, sales) {
      totalSales += sales;
    });

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        'Total Sales for $month: \RM${totalSales.toStringAsFixed(2)}',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  /// Bar Chart for the Entire Year (Summing up all categories for each month)
Widget _buildYearlyBarChart() {
  return Container(
    height: 400,
    padding: EdgeInsets.symmetric(horizontal: 16.0),
    child: BarChart(
      BarChartData(
        alignment: BarChartAlignment.center,
        barGroups: _showingSalesForYear(analyticController.monthlySales),
        titlesData: _buildYearlyTitlesData(),
        borderData: FlBorderData(show: false),
        gridData: FlGridData(show: true, drawVerticalLine: true, drawHorizontalLine: false),
      ),
    ),
  );
}

/// Title formatting for the chart (X-axis) for yearly sales
FlTitlesData _buildYearlyTitlesData() {
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
        List<String> months = [
          'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
          'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
        ];

        if (value.toInt() < months.length) {
          return months[value.toInt()];
        }
        return '';
      },
      margin: 16,
      rotateAngle: 45,
    ),
  );
}

/// Sales data for the entire year
List<BarChartGroupData> _showingSalesForYear(Map<String, Map<String, double>> monthlySales) {
  List<BarChartGroupData> barGroups = [];
  
  List<String> months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];
  
  int index = 0;
  for (String month in months) {
    // Sum sales across all categories for the given month
    double totalSalesForMonth = 0.0;
    Map<String, double> categorySales = monthlySales[month] ?? {};
    
    categorySales.forEach((category, sales) {
      totalSalesForMonth += sales;
    });
    
    barGroups.add(
      BarChartGroupData(
        x: index++,
        barRods: [
          BarChartRodData(
            y: totalSalesForMonth,
            colors: [Styles.primaryColor], 
            width: 15,
            backDrawRodData: BackgroundBarChartRodData(show: false),
          ),
        ],
      ),
    );
  }

  return barGroups;
}
/// Calculate total sales for the year by summing sales for all months and categories
double _calculateTotalSalesForYear(Map<String, Map<String, double>> monthlySales) {
  double totalSales = 0.0;

  monthlySales.forEach((month, categorySales) {
    categorySales.forEach((category, sales) {
      totalSales += sales; // Add sales for each category
    });
  });

  return totalSales;
}

  /// Display ordered products in a table
  Widget _buildOrderedProductsTable() {
  return Table(
    border: TableBorder.all(color: Colors.black),
    columnWidths: {
      0: FixedColumnWidth(150),
      1: FixedColumnWidth(150),
      2: FixedColumnWidth(100),
    },
    children: [
      // Header Row
      TableRow(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Category',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
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
        var category = entry.value['category'];  // Accessing category from the value map
        var quantity = entry.value['quantity'];  // Accessing quantity from the value map
        return TableRow(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(category),
            ),
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