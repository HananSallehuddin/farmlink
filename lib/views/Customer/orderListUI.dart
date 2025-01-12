import 'package:farmlink/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:farmlink/controllers/OrderController.dart';
import 'package:farmlink/models/LocalProduce.dart';
import 'package:farmlink/models/Order.dart' as FarmLinkOrder;

class orderListUI extends StatelessWidget {
  final OrderController orderController = Get.find<OrderController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Orders'),
      ),
      body: FutureBuilder<void>(
        future: orderController.fetchCustomerOrders(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error loading orders.'));
          } else if (orderController.customerOrders.isEmpty) {
            return Center(child: Text('No orders found.'));
          }

          return Obx(() {
            return ListView.builder(
              itemCount: orderController.customerOrders.length,
              itemBuilder: (context, index) {
                final FarmLinkOrder.Order order = orderController.customerOrders[index];
                final LocalProduce? produce = order.produces.isNotEmpty ? order.produces[0] : null;
                String productDetails = order.produces.map((produce) {
                  int quantity = order.quantities[produce.pid] ?? 0;
                  return '${produce.productName} (x$quantity)';
                }).join(', ');

                return Card(
                  margin: EdgeInsets.all(15),
                  color: Styles.primaryColor,
                  child: ListTile(
                    contentPadding: EdgeInsets.all(8.0),
                    leading: produce != null && produce.imageUrls.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              produce.imageUrls[0],
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Icon(Icons.image, size: 50),
                    title: Text(productDetails),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Total Price: \RM${order.totalPrice.toStringAsFixed(2)}'),
                        Text('Order ID: ${order.oid}'),
                      ],
                    ),
                    onTap: () {
                      print('Order tapped: ${order.oid}');
                      orderController.selectedOrder.value = order;
                      if (orderController.selectedOrder.value != null) {
                        Get.toNamed('trackOrder');
                      } else {
                        print('Selected order is null');
                      }
                    },
                  ),
                );
              },
            );
          });
        },
      ),
    );
  }
}