import 'package:farmlink/controllers/OrderController.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:farmlink/models/LocalProduce.dart';

class AnalyticController extends GetxController {
  var totalSales = 0.0.obs;
  final orderController = Get.find<OrderController>();
  var monthlySales = <String, double>{}.obs;
  var mostSoldProduce = ''.obs; // Reactive variable for most sold produce

  Future<void> fetchTotalSales() async {
    try {
      await orderController.fetchSellerOrders();
      totalSales.value = orderController.sellerOrders.fold(0.0, (sum, order) {
        return sum + order.totalPrice;
      });
      print('Total Sales For Seller: \RM${totalSales.value}');
    } catch (e) {
      print('Error fetching total sales for seller: $e');
    }
  }

  Future<void> fetchMonthlySales() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('User not authenticated');
        Get.snackbar('Error', 'Please sign in to fetch sales data');
        return;
      }
      await orderController.fetchSellerOrders();
      Map<String, double> monthlySales = {
        'Jan': 0.0, 'Feb': 0.0, 'Mar': 0.0, 'Apr': 0.0,
        'May': 0.0, 'Jun': 0.0, 'Jul': 0.0, 'Aug': 0.0,
        'Sep': 0.0, 'Oct': 0.0, 'Nov': 0.0, 'Dec': 0.0,
      };
      Map<String, int> produceCount = {};

      for (var order in orderController.sellerOrders) {
        DateTime date = order.orderDate;
        String month = DateFormat.MMM().format(date);
        monthlySales[month] = (monthlySales[month] ?? 0) + order.totalPrice;

        // Loop through each produce item in the order
        for (var produce in order.produces) {
          String produceName = produce.productName; // Assuming 'productName' is the name of the produce
          int quantity = order.quantities[produceName] ?? 0;

          produceCount[produceName] = (produceCount[produceName] ?? 0) + quantity;
        }
      }
      monthlySales.updateAll((key, value) => value.isFinite ? value : 0.0);
      this.monthlySales.assignAll(monthlySales);

      // Determine the most sold produce
      String mostSoldProduce = produceCount.entries.isNotEmpty
          ? produceCount.entries.reduce((a, b) => a.value > b.value ? a : b).key
          : 'No produce sold';

      this.mostSoldProduce.value = mostSoldProduce;
      print('Monthly sales data: $monthlySales');
      print('Most sold produce: $mostSoldProduce');
    } catch (e) {
      print('Error fetching monthly sales: $e');
    }
  }
}