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

  String? _selectedMonth; // Variable to store selected month
  double? _selectedMonthSales; // Variable to store selected month's sales

  @override
  void initState() {
    super.initState();
    // Call the method to fetch ordered products when the UI initializes
    analyticController.fetchOrderedProducts();
    _checkAndFetchDummyData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sales Analytics')),
      body: SingleChildScrollView(
        child: Center(
          child: Obx(() {
            // Observe the orderedProducts map and show loading until it's populated
            if (analyticController.orderedProducts.isEmpty) {
              return CircularProgressIndicator(); // Show loading until data is fetched
            } else {
              return Column(
                children: [
                  SizedBox(height: 100),
                  _buildBarChart(),
                  SizedBox(height: 20),
                  // Display the total sales below the bar chart
                  Text(
                    'Total Sales: RM${analyticController.monthlySales.values.fold(0.0, (sum, sales) => sum + sales).toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  // Only display the sales of the selected month here
                  if (_selectedMonth != null && _selectedMonthSales != null)
                    Text(
                      'Sales for $_selectedMonth: RM${_selectedMonthSales!.toStringAsFixed(2)}',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  SizedBox(height: 20),
                  // Display ordered products with quantities
                  Text(
                    'Ordered Products:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: analyticController.orderedProducts.length,
                    itemBuilder: (context, index) {
                      var productName = analyticController.orderedProducts.keys.toList()[index];
                      var quantity = analyticController.orderedProducts.values.toList()[index];
                      return ListTile(
                        title: Text(productName),
                        subtitle: Text('Quantity: $quantity'),
                      );
                    },
                  ),
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

  void _checkAndFetchDummyData() {
    String currentUserUid = FirebaseAuth.instance.currentUser!.uid;
    if (currentUserUid == 'Xqc1QauV1heZjHtzfnJdQrSoXAO2') {
      analyticController.fetchSalesDummyData();
    }
  }

  Widget _buildBarChart() {
    return Container(
      height: 500,
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          barGroups: _showingMonthlySales(analyticController.monthlySales),
          titlesData: _buildTitlesData(),
          barTouchData: _buildBarTouchData(),
          borderData: FlBorderData(show: false),
          gridData: FlGridData(show: true, drawVerticalLine: true, drawHorizontalLine: false),
        ),
      ),
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
      touchCallback: (response) {
        if (response.spot != null) {
          setState(() {
            // Get the selected month and its sales on touch
            int monthIndex = response.spot!.touchedBarGroupIndex;
            _selectedMonth = _monthFromIndex(monthIndex);
            _selectedMonthSales = analyticController.monthlySales[_selectedMonth];
          });
        }
      },
      touchTooltipData: BarTouchTooltipData(
        tooltipBgColor: Colors.lime[400],
        getTooltipItem: (group, groupIndex, rod, rodIndex) {
          String month = _monthFromIndex(group.x.toInt());
          return BarTooltipItem(
            'RM${rod.y.toStringAsFixed(2)}',
            TextStyle(color: Colors.black),
          );
        },
      ),
    );
  }

  List<String> months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

  int _monthToIndex(String month) {
    return months.indexOf(month);
  }

  String _monthFromIndex(int index) {
    return months[index];
  }
}


// class analyticUI extends StatelessWidget {
//   final AnalyticController analyticController = Get.put(AnalyticController());

//   @override
//   Widget build(BuildContext context) {
//     _checkAndFetchDummyData();

//     return Scaffold(
//       appBar: AppBar(title: Text('Sales Analytics')),
//       body: SingleChildScrollView(
//         child: Center(
//           child: Obx(() {
//             if (analyticController.monthlySales.isEmpty) {
//               return CircularProgressIndicator(); // Show loading until data is fetched
//             } else {
//               return Column(
//                 children: [
//                   SizedBox(height: 100),
//                   _buildBarChart(),
//                   SizedBox(height: 20),
//                   _buildTotalSalesText(),
//                   SizedBox(height: 20),
//                   //_buildOrdersListText(),
//                 ],
//               );
//             }
//           }),
//         ),
//       ),
//     );
//   }

//   void _checkAndFetchDummyData(){
//     String currentUserUid = FirebaseAuth.instance.currentUser!.uid;
//     if (currentUserUid == 'Xqc1QauV1heZjHtzfnJdQrSoXAO2' ) {
//       analyticController.fetchSalesDummyData();
//     }
//   }

//   Widget _buildBarChart() {
//     return Container(
//       height: 400,
//       padding: EdgeInsets.symmetric(horizontal: 16.0),
//       child: BarChart(
//         BarChartData(
//           alignment: BarChartAlignment.spaceAround,
//           barGroups: _showingMonthlySales(analyticController.monthlySales),
//           titlesData: _buildTitlesData(),
//           barTouchData: _buildBarTouchData(),
//           borderData: FlBorderData(show: false),
//           gridData: FlGridData(show: true, drawVerticalLine: true),
//         ),
//       ),
//     );
//   }

//   List<BarChartGroupData> _showingMonthlySales(Map<String, double> monthlySales) {
//     List<BarChartGroupData> barGroups = [];
//     monthlySales.forEach((month, sales) {
//       int index = _monthToIndex(month);
//       barGroups.add(
//         BarChartGroupData(
//           x: index,
//           barRods: [
//             BarChartRodData(
//               y: sales,
//               colors: [Styles.primaryColor],
//               width: 15,
//               backDrawRodData: BackgroundBarChartRodData(show: false),
//             ),
//           ],
//           showingTooltipIndicators: [0],
//         ),
//       );
//     });
//     return barGroups;
//   }

//   FlTitlesData _buildTitlesData() {
//     return FlTitlesData(
//       leftTitles: SideTitles(
//         showTitles: true,
//         getTitles: (value) => value.toInt() % 100 == 0 ? value.toInt().toString() : '',
//         interval: 100,
//         margin: 8,
//       ),
//       bottomTitles: SideTitles(
//         showTitles: true,
//         getTitles: (double value) {
//           return _monthFromIndex(value.toInt());
//         },
//         margin: 16,
//       ),
//     );
//   }

//   BarTouchData _buildBarTouchData() {
//     return BarTouchData(
//       touchTooltipData: BarTouchTooltipData(
//         tooltipBgColor: Colors.lime[400],
//         getTooltipItem: (group, groupIndex, rod, rodIndex) {
//           String month = _monthFromIndex(group.x.toInt());
//           return BarTooltipItem(
//             'RM${rod.y.toStringAsFixed(2)}',
//             TextStyle(color: Colors.black),
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildTotalSalesText() {
//     double totalSales = analyticController.monthlySales.values.fold(0.0, (sum, element) => sum + element);
//     return Text(
//       'Total Sales: RM${totalSales.toStringAsFixed(2)}',
//       style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//     );
//   }

//   // Widget _buildOrdersListText() {
//   //   return FutureBuilder<List<Map<String, dynamic>>>(
//   //     future: analyticController.fetchAllOrdersWithQuantities(),
//   //     builder: (context, snapshot) {
//   //       if (snapshot.connectionState == ConnectionState.waiting) {
//   //         return CircularProgressIndicator();  // Show loading spinner while fetching data
//   //       } else if (snapshot.hasError) {
//   //         return Text('Error: ${snapshot.error}');
//   //       } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//   //         return Text('No orders available');
//   //       } else {
//   //         var orders = snapshot.data!;
//   //         return Column(
//   //           children: orders.map((order) {
//   //             return ListTile(
//   //               title: Text('Order ID: ${order['orderId']}'),
//   //               subtitle: Text('Product ID: ${order['pid']} - Quantity: ${order['quantity']}'),
//   //               trailing: Text('RM${order['totalAmount'].toStringAsFixed(2)}'),
//   //             );
//   //           }).toList(),
//   //         );
//   //       }
//   //     },
//   //   );
//   // }

//   List<String> months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

//   int _monthToIndex(String month) {
//     return months.indexOf(month);
//   }

//   String _monthFromIndex(int index) {
//     return months[index];
//   }
// }