
import 'package:farmlink/models/OrderModel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';


class AnalyticController extends GetxController {
var totalSales = 0.0.obs;
RxMap<String, Map<String, double>> monthlySales = <String, Map<String, double>>{}.obs; // Make this reactive
var orderedProducts = <String, int>{}.obs;
String hardcodedSellerId = 'Xqc1QauV1heZjHtzfnJdQrSoXAO2';



@override
void onInit() {
  super.onInit();
  print('onInit called');
}


Future<void> fetchSalesData() async {

  try {
    String sellerId = FirebaseAuth.instance.currentUser!.uid;
    print('Current Seller ID: $sellerId, Hardcoded Seller ID: $hardcodedSellerId');
        if (sellerId == hardcodedSellerId) {
        // Use dummy data if current user matches the hardcoded seller ID
        populateDummyDataForChart();
        return; // Exit early after populating dummy data
      }

    double totalSales = 0.0;
    

    print('Real Seller ID: $sellerId');

    // Fetch orders for the current seller
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('orders')
        .where('sellerIds', arrayContains: sellerId)
        .get();

    print('Fetched orders count for real seller: ${querySnapshot.docs.length}');

    if (querySnapshot.docs.isEmpty) {
      print('No orders found for this seller.');
      return; // Exit early if no orders are found
    }

    // Process each order
    for (var doc in querySnapshot.docs) {
      var orderData = doc.data() as Map<String, dynamic>;
      print('Order Data: $orderData');

      double orderTotalAmount = 0.0;
      if (orderData.containsKey('totalAmount')) {
        // Ensure correct type casting for totalAmount
        orderTotalAmount = (orderData['totalAmount'] is double)
            ? orderData['totalAmount']
            : (orderData['totalAmount'] is int)
                ? (orderData['totalAmount'] as int).toDouble()
                : 0.0;
      }

      totalSales += orderTotalAmount;
      print('Running total sales for real data: $totalSales');
    }

    this.totalSales.value = totalSales;
    print('Final Total Sales for real data: $totalSales');

    // Update `monthlySales` map for real data
    if (querySnapshot.docs.isNotEmpty) {
      var month = DateFormat('MMM').format(DateTime.now()); // Get the current month

      // Initialize the category map for the month if it doesn't exist
      if (!monthlySales.containsKey(month)) {
        monthlySales[month] = {
          'Fruits': 0.0,
          'Vegetables': 0.0,
          'Herbs': 0.0,
          'Others': 0.0,
        };
      }

      // Process each order's products and update category sales
      for (var doc in querySnapshot.docs) {
        var orderData = doc.data() as Map<String, dynamic>;
        var products = List<Map<String, dynamic>>.from(orderData['products'] ?? []);
        var quantities = Map<String, dynamic>.from(orderData['quantities'] ?? {});

        for (int i = 0; i < products.length; i++) {
          var product = products[i];
          var pid = product['pid'];
          var productCategory = product['category'] ?? 'Others'; // Default to 'Others' if category is missing
          var quantity = quantities[pid] ?? 0;

          // Assuming each product has a price and is part of the total amount
          var productPrice = product['price'] ?? 0.0; // Default to 0 if price is missing
          var productSales = productPrice * quantity;

          // Update monthly sales for the category
          if (monthlySales[month] != null) {
            monthlySales[month]![productCategory] =
                (monthlySales[month]![productCategory] ?? 0.0) + productSales;
          }
        }
      }

      print('Monthly Sales Updated for real data: $monthlySales');
    }
  } catch (e) {
    print('Error fetching sales data: $e');
  }
}

void populateDummyDataForChart() {
  print("Populating dummy data for chart...");
    totalSales.value = 5000.0;

    // Monthly sales dummy data
    monthlySales.value = {
  "Jan": {
    "Fruits": 1500.0,
    "Vegetables": 2000.0,
    "Herbs": 500.0,
    "Others": 1000.0,
  },
  "Feb": {
    "Fruits": 1200.0,
    "Vegetables": 2200.0,
    "Herbs": 800.0,
    "Others": 800.0,
  },
  "Mar": {
    "Fruits": 1600.0,
    "Vegetables": 1800.0,
    "Herbs": 700.0,
    "Others": 900.0,
  },
  "Apr": {
    "Fruits": 1700.0,
    "Vegetables": 1900.0,
    "Herbs": 600.0,
    "Others": 1100.0,
  },
  "May": {
    "Fruits": 1800.0,
    "Vegetables": 2000.0,
    "Herbs": 900.0,
    "Others": 950.0,
  },
  "Jun": {
    "Fruits": 1900.0,
    "Vegetables": 2100.0,
    "Herbs": 650.0,
    "Others": 1000.0,
  },
  "Jul": {
    "Fruits": 2000.0,
    "Vegetables": 2200.0,
    "Herbs": 550.0,
    "Others": 1050.0,
  },
  "Aug": {
    "Fruits": 2100.0,
    "Vegetables": 2300.0,
    "Herbs": 750.0,
    "Others": 1100.0,
  },
  "Sep": {
    "Fruits": 2200.0,
    "Vegetables": 2400.0,
    "Herbs": 800.0,
    "Others": 1150.0,
  },
  "Oct": {
    "Fruits": 2300.0,
    "Vegetables": 2500.0,
    "Herbs": 900.0,
    "Others": 1200.0,
  },
  "Nov": {
    "Fruits": 2400.0,
    "Vegetables": 2600.0,
    "Herbs": 850.0,
    "Others": 1250.0,
  },
  "Dec": {
    "Fruits": 2500.0,
    "Vegetables": 2700.0,
    "Herbs": 1000.0,
    "Others": 1300.0,
  },
};

    // Ordered products dummy data
    orderedProducts.value = {
      "Apples": 120,
      "Carrots": 150,
      "Basil": 50,
      "Potatoes": 100,
    };
  }


// // Fetch dummy data for testing (Hardcoded Seller)
// Future<void> fetchSalesDummyData() async {
// try {
// double totalSales = 0.0;


// String sellerId = 'Xqc1QauV1heZjHtzfnJdQrSoXAO2'; // Hardcoded seller ID for dummy data
// print('Dummy Seller ID: $sellerId');


// // Define categories and their respective sales data (category -> month -> sales)
// Map<String, Map<String, double>> categorizedSalesData = {
// 'Fruits': {
// 'Jan': 300.0,
// 'Feb': 350.0,
// 'Mar': 450.0,
// 'Apr': 500.0,
// 'May': 550.0,
// 'Jun': 600.0,
// 'Jul': 550.0,
// 'Aug': 525.0,
// 'Sep': 550.0,
// 'Oct': 600.0,
// 'Nov': 700.0,
// 'Dec': 800.0,
// },
// 'Vegetables': {
// 'Jan': 200.0,
// 'Feb': 250.0,
// 'Mar': 300.0,
// 'Apr': 350.0,
// 'May': 400.0,
// 'Jun': 450.0,
// 'Jul': 420.0,
// 'Aug': 400.0,
// 'Sep': 430.0,
// 'Oct': 470.0,
// 'Nov': 500.0,
// 'Dec': 600.0,
// },
// 'Herbs': {
// 'Jan': 100.0,
// 'Feb': 120.0,
// 'Mar': 150.0,
// 'Apr': 200.0,
// 'May': 220.0,
// 'Jun': 250.0,
// 'Jul': 240.0,
// 'Aug': 230.0,
// 'Sep': 240.0,
// 'Oct': 250.0,
// 'Nov': 300.0,
// 'Dec': 350.0,
// },
// 'Others': {
// 'Jan': 400.0,
// 'Feb': 480.0,
// 'Mar': 600.0,
// 'Apr': 750.0,
// 'May': 830.0,
// 'Jun': 1000.0,
// 'Jul': 990.0,
// 'Aug': 945.0,
// 'Sep': 1000.0,
// 'Oct': 1280.0,
// 'Nov': 1500.0,
// 'Dec': 1750.0,
// },
// };


// monthlySales.value = {}; // Reset to an empty map to make sure it's updated properly


// // Calculate total sales and update monthlySales with categorized data
// categorizedSalesData.forEach((category, monthlyData) {
// monthlyData.forEach((month, sales) {
// totalSales += sales;
// print('Sales for $category in $month: $sales');
// // Ensure monthlySales contains all categories for each month
// if (!monthlySales.containsKey(month)) {
// monthlySales[month] = {
// 'Fruits': 0.0,
// 'Vegetables': 0.0,
// 'Herbs': 0.0,
// 'Others': 0.0,
// };
// }


// // Add sales for the category to the specific month
// monthlySales[month]![category] = (monthlySales[month]![category] ?? 0.0) + sales;
// });
// });


// this.totalSales.value = totalSales;
// print('Final Total Sales (Dummy): $totalSales');


// // Update categorizedSalesData
// print('Categorized Monthly Sales Updated: $categorizedSalesData');


// } catch (e) {
// print('Error fetching dummy sales data: $e');
// }
// }


Future<void> fetchOrderedProducts() async {
try {
var ordersSnapshot = await FirebaseFirestore.instance.collection('orders').get();
Map<String, int> productQuantities = {};
final currentUserId = FirebaseAuth.instance.currentUser?.uid;


for (var doc in ordersSnapshot.docs) {
var orderData = doc.data() as Map<String, dynamic>;
var products = List<Map<String, dynamic>>.from(orderData['products'] ?? []);
var quantities = Map<String, dynamic>.from(orderData['quantities'] ?? {});


// Check if the current user is the seller involved in any of the products
for (int i = 0; i < products.length; i++) {
var product = products[i];
var pid = product['pid'];
var quantity = quantities[pid];
quantity = (quantity is int) ? quantity : quantity?.toInt();


// Only process products if they belong to the current seller
if (product['userRef']?.id == currentUserId || product['sellerId'] == currentUserId) {
var productSnapshot = await FirebaseFirestore.instance
.collection('localProduce')
.doc(pid)
.get();


if (productSnapshot.exists) {
var productData = productSnapshot.data() as Map<String, dynamic>;
var productName = productData['productName'];


if (productQuantities.containsKey(productName)) {
productQuantities[productName] = ((productQuantities[productName] as num? ?? 0).toInt() + (quantity?.toInt() ?? 0)).toInt();
} else {
productQuantities[productName] = quantity ?? 0;
}
}
}
}
}


// Update the ordered products with the quantities
orderedProducts.value = Map<String, int>.from(
productQuantities.map((key, value) => MapEntry(key, (value as num).toInt()))
);


print('Ordered Products with Quantities: $orderedProducts');
} catch (e) {
print("Error fetching ordered products: $e");
}

}
}