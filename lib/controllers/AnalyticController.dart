import 'package:farmlink/models/OrderModel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class AnalyticController extends GetxController {
  var totalSales = 0.0.obs;
  var monthlySales = <String, double>{}.obs;
  var orderedProducts = <String, int>{}.obs;  // Initialize as an RxMap

  @override
  void onInit() {
    super.onInit();
    print('onInit called');
    fetchSalesData();
  }

  // Fetch total sales data for the seller
  Future<void> fetchSalesData() async {
    try {
      double totalSales = 0.0;
      String sellerId = FirebaseAuth.instance.currentUser!.uid;

      // Log the sellerId to make sure it's correct
      print('Seller ID: $sellerId');

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('orders')
          .where('sellerIds', arrayContains: sellerId)
          .get();

      print('Fetched orders count: ${querySnapshot.docs.length}');  // Check if orders are being fetched

      if (querySnapshot.docs.isEmpty) {
        print('No orders found for this seller.');
      }

      for (var doc in querySnapshot.docs) {
        var orderData = doc.data() as Map<String, dynamic>;
        print('Order Data: $orderData');  // Log the order data for each document

        double orderTotalAmount = 0.0;
        if (orderData.containsKey('totalAmount')) {
          orderTotalAmount = (orderData['totalAmount'] is double)
              ? orderData['totalAmount']
              : orderData['totalAmount'].toDouble();
        }

        totalSales += orderTotalAmount;
        print('Running total sales: $totalSales');  // Check the running total
      }

      this.totalSales.value = totalSales;
      print('Final Total Sales: $totalSales');

      // Update `monthlySales` map
      if (querySnapshot.docs.isNotEmpty) {
        var month = DateFormat('MMM').format(DateTime.now()); // Current month for example
        monthlySales[month] = totalSales;
        print('Monthly Sales Updated: $monthlySales');
      }

    } catch (e) {
      print('Error fetching sales data: $e');
    }
  }

  Future<void> fetchSalesDummyData() async {
  try {
    double totalSales = 0.0;

    String sellerId = 'Xqc1QauV1heZjHtzfnJdQrSoXAO2';  // Hardcoded seller ID for dummy data
    print('Seller ID: $sellerId');

    // Simulate sales for 12 months (January to December)
    Map<String, double> dummyMonthlySales = {
      'Jan': 1000.0,
      'Feb': 1200.0,
      'Mar': 1500.0,
      'Apr': 1800.0,
      'May': 2000.0,
      'Jun': 2500.0,
      'Jul': 2200.0,
      'Aug': 2100.0,
      'Sep': 2300.0,
      'Oct': 2600.0,
      'Nov': 3000.0,
      'Dec': 3500.0,
    };

    // Use dummy data to calculate total sales for the year
    dummyMonthlySales.forEach((month, sales) {
      totalSales += sales;
      print('Sales for $month: $sales');
    });

    this.totalSales.value = totalSales;
    print('Final Total Sales (Dummy): $totalSales');

    // Update `monthlySales` map with dummy data (cast to RxMap)
    monthlySales.value = RxMap<String, double>.from(dummyMonthlySales);
    print('Monthly Sales Updated (Dummy): $monthlySales');

  } catch (e) {
    print('Error fetching dummy sales data: $e');
  }
}

// Fetch ordered products and their quantities from orders
Future<void> fetchOrderedProducts() async {
  try {
    var ordersSnapshot = await FirebaseFirestore.instance.collection('orders').get();
    Map<String, int> productQuantities = {}; // To store product names and quantities

    for (var doc in ordersSnapshot.docs) {
      var orderData = doc.data() as Map<String, dynamic>;
      
      // Extract product details
      var products = List<Map<String, dynamic>>.from(orderData['products'] ?? []);
      var quantities = Map<String, dynamic>.from(orderData['quantities'] ?? {});

      // Loop through products and aggregate quantities
      for (int i = 0; i < products.length; i++) {
        var product = products[i];
        var pid = product['pid']; // Product ID
        var quantity = quantities[pid]; // Quantity for the product

        // Ensure quantity is treated as an integer (cast if necessary)
        quantity = (quantity is int) ? quantity : quantity?.toInt();

        // Fetch product name from 'localProduce' collection using product ID
        var productSnapshot = await FirebaseFirestore.instance
            .collection('localProduce')
            .doc(pid)
            .get();

        if (productSnapshot.exists) {
          var productData = productSnapshot.data() as Map<String, dynamic>;
          var productName = productData['productName'];

          // Update product quantities
          if (productQuantities.containsKey(productName)) {
          productQuantities[productName] = ((productQuantities[productName] as num? ?? 0).toInt() + (quantity?.toInt() ?? 0)).toInt();
          } else {
                      productQuantities[productName] = quantity ?? 0;
                    }
                  }
                }
    }
    orderedProducts.value = Map<String, int>.from(
  productQuantities.map((key, value) => MapEntry(key, (value as num).toInt()))
);

    // Update the orderedProducts map
    //orderedProducts.value = productQuantities;
    print('Ordered Products with Quantities: $orderedProducts');
  } catch (e) {
    print("Error fetching ordered products: $e");
  }
}


  // Fetch all orders with their quantities sold
//   Future<List<Map<String, dynamic>>> fetchAllOrdersWithQuantities() async {
//   try {
//     var snapshot = await FirebaseFirestore.instance.collection('orders').get();
//     return snapshot.docs.map((doc) {
//       return {
//         'orderId': doc['orderId'],
//         'pid': doc['pid'],
//         'quantity': doc['quantity'],
//         'totalAmount': doc['totalAmount'],
//       };
//     }).toList();
//   } catch (e) {
//     print("Error fetching all orders with quantities: $e");
//     return [];
//   }
// }
}