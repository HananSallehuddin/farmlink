import 'package:farmlink/models/LocalProduce.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:farmlink/controllers/OrderController.dart';
import 'package:farmlink/models/Order.dart' as FarmLinkOrder;

class orderListUI extends StatelessWidget {
final OrderController orderController = Get.find<OrderController>();

  @override
  Widget build(BuildContext context) {
    // Fetch orders
    orderController.fetchCustomerOrders();

    return Scaffold(
      appBar: AppBar(
        title: Text('My Orders'),
      ),
      body: Obx(() {
        // If there are no orders
        if (orderController.customerOrders.isEmpty) {
          return Center(child: Text('No orders found.'));
        }

        return ListView.builder(
          itemCount: orderController.customerOrders.length,
          itemBuilder: (context, index) {
            final FarmLinkOrder.Order order = orderController.customerOrders[index];
            final LocalProduce? produce = order.produces.isNotEmpty ? order.produces[0] : null;

            return Card(
              margin: EdgeInsets.symmetric(vertical: 10),
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
                //title: Text('Order ID: ${order.oid}'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Total Price: \$${order.totalPrice.toStringAsFixed(2)}'),
                    if (produce != null)
                      Text(
                        'Product: ${produce.productName}', // Display the product name
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                  ],
                ),
                onTap: () {
                  // Navigate to order details page or perform another action
                },
              ),
            );
          },
        );
      }),
    );
  }
}
