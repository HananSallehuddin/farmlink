import 'package:farmlink/controllers/CartController.dart';
import 'package:farmlink/models/Cart.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:farmlink/models/LocalProduce.dart';

class AnalyticController extends GetxController {
  var totalSales = 0.0.obs;
  final cartController = Get.find<CartController>();
  var monthlySales = <String, double>{}.obs;
  var mostSoldProduce = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchSalesData();
  }

  Future<void> fetchSalesData() async {
    try {
      // Assuming we can access sales data from the cart or related transactions
      // In the absence of orders, we'll fetch relevant data from cart transactions

      Map<String, double> monthlySalesData = {
        'Jan': 0.0, 'Feb': 0.0, 'Mar': 0.0, 'Apr': 0.0,
        'May': 0.0, 'Jun': 0.0, 'Jul': 0.0, 'Aug': 0.0,
        'Sep': 0.0, 'Oct': 0.0, 'Nov': 0.0, 'Dec': 0.0,
      };
      Map<String, int> produceCount = {};

      // Fetch and process cart data (assuming cart transactions or completed carts)
      var carts = await _fetchCartsForSeller(); // Method to fetch carts related to the seller

      for (var cart in carts) {
        DateTime date = cart.timestamp;
        String month = DateFormat.MMM().format(date);
        double cartTotal = cart.totalAmount;

        monthlySalesData[month] = (monthlySalesData[month] ?? 0) + cartTotal;

        // Calculate produce count from cart items
        cart.produces.forEach((produce) {
          String produceName = produce.productName;
          int quantity = cart.quantity[produce.pid] ?? 0;

          produceCount[produceName] = (produceCount[produceName] ?? 0) + quantity;
        });
      }

      monthlySalesData.updateAll((key, value) => value.isFinite ? value : 0.0);
      monthlySales.assignAll(monthlySalesData);

      // Determine the most sold produce
      mostSoldProduce.value = produceCount.entries.isNotEmpty
          ? produceCount.entries.reduce((a, b) => a.value > b.value ? a : b).key
          : 'No produce sold';

      print('Monthly sales data: $monthlySalesData');
      print('Most sold produce: $mostSoldProduce');
    } catch (e) {
      print('Error fetching sales data: $e');
    }
  }

  Future<List<Cart>> _fetchCartsForSeller() async {
    // Logic to fetch carts related to the seller
    // This is a placeholder function; actual implementation will depend on your database schema
    List<Cart> carts = []; // Fetch carts from Firestore or other database
    return carts;
  }
}