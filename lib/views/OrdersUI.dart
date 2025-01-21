import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:farmlink/controllers/OrderController.dart';
import 'package:farmlink/controllers/UserController.dart';
import 'package:farmlink/styles.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:farmlink/bottomNaviBarCustomer.dart';
import 'package:farmlink/bottomNaviBarSeller.dart';

class OrdersUI extends StatefulWidget {
  @override
  _OrdersUIState createState() => _OrdersUIState();
}

class _OrdersUIState extends State<OrdersUI> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final orderController = Get.put(OrderController());
  final userController = Get.find<UserController>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Orders'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Active Orders'),
            Tab(text: 'Past Orders'),
          ],
          labelColor: Styles.primaryColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Styles.primaryColor,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOrdersList(orderController.activeOrders),
          _buildOrdersList(orderController.pastOrders),
        ],
      ),
      bottomNavigationBar: GetBuilder<UserController>(builder: (controller) {
        final role = controller.currentUser.value?.role ?? '';
        return role == 'Seller'
            ? bottomNavigationBarSeller(currentRoute: '/orders')
            : bottomNavigationBarCustomer(currentRoute: '/orders');
      }),
    );
  }

  Widget _buildOrdersList(RxList<QueryDocumentSnapshot> orders) {
    return Obx(() {
      if (orders.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.receipt_long_outlined,
                size: 64,
                color: Colors.grey[400],
              ),
              SizedBox(height: 16),
              Text(
                'No orders found',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                ),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final orderDoc = orders[index];
          final orderData = orderDoc.data() as Map<String, dynamic>;
          return _buildOrderCard(
            orderId: orderDoc.id,
            orderData: orderData,
          );
        },
      );
    });
  }

  Widget _buildOrderCard({
    required String orderId,
    required Map<String, dynamic> orderData,
  }) {
    final orderDate = (orderData['orderDate'] as Timestamp).toDate();
    final formattedDate = DateFormat('MMM dd, yyyy, hh:mm a').format(orderDate);
    final status = orderData['status'] as String;
    final totalAmount = orderData['totalAmount'] as double;
    final products = List<Map<String, dynamic>>.from(orderData['products'] ?? []);
    final currentRole = Get.find<UserController>().currentUser.value?.role;
    final quantities = Map<String, dynamic>.from(orderData['quantities'] ?? {});

    if (currentRole == 'Seller') {
      final currentUserId = FirebaseAuth.instance.currentUser?.uid;
      products.removeWhere((product) => 
        product['userRef']?.id != currentUserId && product['sellerId'] != currentUserId
      );
    }

    return Card(
      elevation: 4,
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: _getStatusColor(status).withOpacity(0.1),
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order #${orderId.substring(0, 8)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      formattedDate,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                _buildStatusChip(status),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Products',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 8),
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    final quantity = quantities[product['pid']] ?? 1;
                    return _buildProductItem(product, quantity);
                  },
                ),
                SizedBox(height: 16),
                Text(
                  'Total Amount: \RM${totalAmount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                if (currentRole == 'Seller') _buildStatusButton(orderId, status),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductItem(Map<String, dynamic> product, int quantity) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CachedNetworkImage(
          imageUrl: product['imageUrls'][0],
          width: 50,
          height: 50,
          fit: BoxFit.cover,
          placeholder: (context, url) => CircularProgressIndicator(),
          errorWidget: (context, url, error) => Icon(Icons.error),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                product['productName'],
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Quantity: $quantity',
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(String status) {
    Color chipColor;
    switch (status) {
      case 'pending':
        chipColor = Colors.orange;
        break;
      case 'processing':
        chipColor = Colors.blue;
        break;
      case 'shipped':
        chipColor = Colors.green;
        break;
      case 'delivered':
        chipColor = Colors.grey;
        break;
      case 'cancelled':
        chipColor = Colors.red;
        break;
      default:
        chipColor = Colors.grey;
    }
    return Chip(
      label: Text(
        status.capitalizeFirst!,
        style: TextStyle(color: Colors.white),
      ),
      backgroundColor: chipColor,
    );
  }

  Widget _buildStatusButton(String orderId, String status) {
    final newStatus = _getNextStatus(status);
    return ElevatedButton(
      onPressed: () => Get.find<OrderController>().updateOrderStatus(orderId, newStatus),
      child: Text('Mark as $newStatus'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Styles.primaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  String _getNextStatus(String currentStatus) {
    switch (currentStatus) {
      case 'pending':
        return 'processing';
      case 'processing':
        return 'shipped';
      case 'shipped':
        return 'delivered';
      default:
        return currentStatus;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'processing':
        return Colors.blue;
      case 'shipped':
        return Colors.green;
      case 'delivered':
        return Colors.grey;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}