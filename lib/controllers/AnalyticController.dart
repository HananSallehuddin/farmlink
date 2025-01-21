import 'package:farmlink/models/OrderModel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class AnalyticController extends GetxController {
  var totalSales = 0.0.obs;
  var monthlySales = <String, double>{}.obs;
  var mostSoldProduce = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchSalesData();
  }

Future<void> fetchSalesData() async {
  try {
    Map<String, double> monthlySalesData = {
      'Jan': 0.0, 'Feb': 0.0, 'Mar': 0.0, 'Apr': 0.0,
      'May': 0.0, 'Jun': 0.0, 'Jul': 0.0, 'Aug': 0.0,
      'Sep': 0.0, 'Oct': 0.0, 'Nov': 0.0, 'Dec': 0.0,
    };

    Map<String, int> produceCount = {};

    // Fetch orders for the current seller
    String sellerId = FirebaseAuth.instance.currentUser!.uid;
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('orders')
        .where('sellerIds', arrayContains: sellerId)
        .get();

    // Process each order
    for (var doc in querySnapshot.docs) {
      var order = OrderModel.fromJson(doc.data() as Map<String, dynamic>);
      DateTime date = order.orderDate;
      String month = DateFormat.MMM().format(date);
      double orderTotal = order.totalAmount;

      // Update monthly sales data
      monthlySalesData[month] = (monthlySalesData[month] ?? 0) + orderTotal;

      // Log the products to check for any unexpected data type
      print('Order Products: ${order.products.runtimeType}');  // Type of products
      print('Order Products Data: ${order.products}');  // Raw product data

      // Iterate over the products and catch potential type issues
      for (var product in order.products) {
        try {
          if (product is Map<String, dynamic>) {
            String productName = product['productName'];  // Ensure this is a String
            int quantity = product['quantity'];  // Ensure quantity is an int
            print('Processed Produce Name: $productName');
            print('Quantity: $quantity');

            // Update the produce count safely
            produceCount[productName] = (produceCount[productName] ?? 0) + quantity;
          } else {
            print('Error: Product is not a Map<String, dynamic>: $product');
          }
        } catch (e) {
          print('Error processing product: $e');
        }
      }
    }

    // Update monthly sales data
    monthlySalesData.updateAll((key, value) => value.isFinite ? value : 0.0);
    monthlySales.assignAll(monthlySalesData);

    // Determine the most sold produce
    mostSoldProduce.value = produceCount.isNotEmpty
        ? produceCount.entries.reduce((a, b) => a.value > b.value ? a : b).key
        : 'No produce sold';

    print('Monthly sales data: $monthlySalesData');
    print('Most sold produce: $mostSoldProduce');
  } catch (e) {
    print('Error fetching sales data: $e');
  }
}
}