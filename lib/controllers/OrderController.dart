import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:farmlink/controllers/UserController.dart';

class OrderController extends GetxController {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final userController = Get.find<UserController>();

  RxList<QueryDocumentSnapshot> activeOrders = <QueryDocumentSnapshot>[].obs;
  RxList<QueryDocumentSnapshot> pastOrders = <QueryDocumentSnapshot>[].obs;
  RxBool isLoading = true.obs;
  RxBool isProcessing = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeOrders();
  }

  void _initializeOrders() {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) return;

    isLoading.value = true;

    try {
      // Listen to active orders
      _listenToOrders(['pending', 'processing', 'shipped'], activeOrders);

      // Listen to past orders
      _listenToOrders(['delivered', 'cancelled'], pastOrders);
    } catch (e) {
      print('Error initializing orders: $e');
      Get.snackbar(
        'Error',
        'Failed to load orders',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void _listenToOrders(List<String> statusList, RxList<QueryDocumentSnapshot> ordersList) {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) return;

    final userRole = userController.currentUser.value?.role;

    if (userRole == 'Customer') {
      _firestore
          .collection('orders')
          .where('userId', isEqualTo: currentUserId)
          .where('status', whereIn: statusList)
          .orderBy('orderDate', descending: true)
          .snapshots()
          .listen(
            (snapshot) => ordersList.value = snapshot.docs,
            onError: (error) {
              print('Error in customer orders query: $error');
              ordersList.value = [];
            },
          );
    } else if (userRole == 'Seller') {
      _firestore
          .collection('orders')
          .where('status', whereIn: statusList)
          .orderBy('orderDate', descending: true)
          .snapshots()
          .listen(
            (snapshot) {
              // Filter orders that contain products from this seller
              List<QueryDocumentSnapshot> sellerOrders = snapshot.docs.where((doc) {
                Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
                List<Map<String, dynamic>> products = List<Map<String, dynamic>>.from(data['products'] ?? []);
                return products.any((product) => 
                  product['userRef']?.id == currentUserId || product['sellerId'] == currentUserId
                );
              }).toList();
              ordersList.value = sellerOrders;
            },
            onError: (error) {
              print('Error in seller orders query: $error');
              ordersList.value = [];
            },
          );
    }
  }

  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    try {
      isProcessing.value = true;
      await _firestore.collection('orders').doc(orderId).update({
        'status': newStatus,
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      Get.snackbar(
        'Success',
        'Order status updated to ${newStatus.capitalizeFirst}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print('Error updating order status: $e');
      Get.snackbar(
        'Error',
        'Failed to update order status',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isProcessing.value = false;
    }
  }
}