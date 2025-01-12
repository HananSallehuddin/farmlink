import 'package:farmlink/controllers/OrderController.dart';
import 'package:farmlink/models/LocalProduce.dart';
import 'package:farmlink/styles.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:farmlink/models/Order.dart' as FarmLinkOrder;
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class sellerOrderListUI extends StatelessWidget {
  final OrderController orderController = Get.find<OrderController>();
  bool _isOrdersFetched = false;

  @override
  Widget build(BuildContext context) {
    if (!_isOrdersFetched) {
      print('Fetching orders...');
      orderController.fetchSellerOrders();
      _isOrdersFetched = true;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Customer Orders'),
      ),
      body: Obx(() {
        print('Displaying sellerOrders length: ${orderController.sellerOrders.length}');
        if (orderController.sellerOrders.isEmpty) {
          return Center(child: Text('No orders found.'));
        }

        return ListView.builder(
          itemCount: orderController.sellerOrders.length,
          itemBuilder: (context, index) {
            final FarmLinkOrder.Order order = orderController.sellerOrders[index];

            Future<DocumentSnapshot> customerSnapshot = order.customerRef!.get();

            return FutureBuilder<DocumentSnapshot>(
              future: customerSnapshot,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return Center(child: Text('Customer not found.'));
                }

                var customerData = snapshot.data!.data() as Map<String, dynamic>;
                String customerUsername = customerData['username'] ?? 'Unknown Username';

                return Card(
                  margin: EdgeInsets.all(15),
                  color: Styles.primaryColor,
                  child: ListTile(
                    title: Text('Customer: $customerUsername'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Total Price: \RM${order.totalPrice.toStringAsFixed(2)}'),
                        Text('Order ID: ${order.oid}'),
                        Text('Status: ${order.status}'),
                        SizedBox(height: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: order.produces.asMap().entries.map((entry) {
                            int index = entry.key;
                            LocalProduce produce = entry.value;
                            int quantity = order.quantities[produce.pid] ?? 0;

                            return Row(
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
                                Text(
                                  '${produce.productName} (x$quantity)', 
                                  style: TextStyle(fontSize: 16),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                    onTap: () {
                      orderController.selectedOrder.value = order;
                      Get.toNamed('updateOrderStatus');
                    },
                  ),
                );
              },
            );
          },
        );
      }),
    );
  }
}