import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:farmlink/controllers/OrderController.dart';
import 'package:farmlink/models/Order.dart' as FarmLinkOrder;

class trackOrderUI extends StatelessWidget {
  final orderController = Get.find<OrderController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Track Order'),
      ),
      body: Obx(() {
        final order = orderController.selectedOrder.value;

        if (order == null) {
          return Center(child: Text('No order selected.'));
        }

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Order ID: ${order.oid}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              Text('Status: ${order.status}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              Text('Total Price: \RM${order.totalPrice.toStringAsFixed(2)}'),
              SizedBox(height: 20),
              Text('Items:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ListView.builder(
                shrinkWrap: true,
                itemCount: order.produces.length,
                itemBuilder: (context, index) {
                  final produce = order.produces[index];
                  final quantity = order.quantities[produce.pid] ?? 0;

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: Row(
                      children: [
                        produce.imageUrls.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  produce.imageUrls[0],
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Icon(Icons.image, size: 60),
                        SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(produce.productName, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            Text('Quantity: x$quantity', style: TextStyle(fontSize: 14)),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        );
      }),
    );
  }
}