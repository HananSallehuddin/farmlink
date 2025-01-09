import 'package:farmlink/controllers/OrderController.dart';
import 'package:flutter/material.dart';
import 'package:farmlink/models/Order.dart' as FarmLinkOrder;
import 'package:get/get.dart';

class sellerOrderListUI extends StatelessWidget {
  final OrderController orderController = Get.find<OrderController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Seller Orders'),
      ),
      body: Obx(() {
        if (orderController.sellerOrders.isEmpty) {
          return Center(child: Text('No orders for your products.'));
        }
        if (orderController.sellerOrders.isEmpty && !orderController.sellerOrders.isEmpty) {
          // Display a loading indicator while orders are being fetched
          return Center(child: CircularProgressIndicator());
        }
        return ListView.builder(
          itemCount: orderController.sellerOrders.length,
          itemBuilder: (context, index) {
            final FarmLinkOrder.Order order = orderController.sellerOrders[index];
            return Card(
              margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 5,
              child: ListTile(
                title: Text('Order ID: ${order.oid}'),
                subtitle: Text('Total Price: \$${order.totalPrice.toStringAsFixed(2)}'),
                onTap: () {
                  // Navigate to order details page or show order details in a dialog
                  _showOrderDetails(context, order);
                },
              ),
            );
          },
        );
      }),
    );
  }

  void _showOrderDetails(BuildContext context, FarmLinkOrder.Order order) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Order Details'),
          content: Text('Order ID: ${order.oid}\nTotal Price: \$${order.totalPrice.toStringAsFixed(2)}'),
          actions: [
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}