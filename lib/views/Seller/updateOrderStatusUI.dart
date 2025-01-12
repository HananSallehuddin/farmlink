import 'package:farmlink/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:farmlink/controllers/OrderController.dart';
import 'package:farmlink/models/Order.dart' as FarmLinkOrder;
import 'package:farmlink/models/LocalProduce.dart';  
import 'package:cloud_firestore/cloud_firestore.dart';

class updateOrderStatusUI extends StatelessWidget {
  final orderController = Get.find<OrderController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Update Order Status'),
      ),
      body: Obx(() {
        final order = orderController.selectedOrder.value;

        if (order == null) {
          return Center(child: Text('No order selected.'));
        }

        final currentStatus = order.status; 
        List<String> statuses = ['Pending', 'In Progress', 'Shipped', 'Delivered'];

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, 
              children: [
             
                FutureBuilder<DocumentSnapshot>(
                  future: order.customerRef!.get(), 
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    }

                    if (!snapshot.hasData || !snapshot.data!.exists) {
                      return Text('Customer not found.');
                    }

                    var customerData = snapshot.data!.data() as Map<String, dynamic>;
                    String customerUsername = customerData['username'] ?? 'Unknown Username';

                    return Text(
                      'Customer: $customerUsername',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    );
                  },
                ),
                SizedBox(height: 10),

                Text(
                  'Order Details:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                ListView.builder(
                  shrinkWrap: true,  
                  physics: NeverScrollableScrollPhysics(),  
                  itemCount: order.produces.length,
                  itemBuilder: (context, index) {
                    LocalProduce produce = order.produces[index];
                    int quantity = order.quantities[produce.pid] ?? 0;

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
                SizedBox(height: 10),

                Text(
                  'Current Status: $currentStatus',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                Text(
                  'Select New Status:',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 20),

                Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Line connector for statuses that aren't 'Delivered'
                      if (currentStatus != 'Delivered') ...[
                        Positioned(
                          top: 10,
                          bottom: 10,
                          child: Container(
                            width: 2,
                            height: 180, 
                            color: Colors.grey, 
                          ),
                        ),
                      ],
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(statuses.length, (index) {
                          final status = statuses[index];
                          bool isSelected = currentStatus.toLowerCase() == status.toLowerCase(); // Case-insensitive comparison

                          return GestureDetector(
                            onTap: () {
                              _showConfirmationDialog(context, order, status);
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 10),
                              child: Column(
                                children: [
                                  CircleAvatar(
                                    radius: 30,
                                    backgroundColor: isSelected ? Styles.primaryColor : Colors.grey,
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    status,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                      color: isSelected ? Styles.primaryColor : Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  // Confirmation dialog before updating order status
  void _showConfirmationDialog(BuildContext context, FarmLinkOrder.Order order, String newStatus) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Status Update'),
          content: Text(
              'Are you sure you want to update the status of Order ID ${order.oid} to $newStatus?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                orderController.updateOrderStatus(newStatus);
                Navigator.of(context).pop();
              },
              child: Text('Confirm'),
            ),
          ],
        );
      },
    );
  }
}