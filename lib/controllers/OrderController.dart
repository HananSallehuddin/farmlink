import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:farmlink/controllers/UserController.dart';
import 'package:farmlink/services/NotificationService.dart';

class OrderController extends GetxController {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final userController = Get.find<UserController>();
  final notificationService = Get.find<NotificationService>();

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
                    product['userRef']?.id == currentUserId ||
                    product['sellerId'] == currentUserId);
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

  Future<void> markOrdersAsRead() async {
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser == null) return;

      WriteBatch batch = _firestore.batch();
      String role = userController.currentUser.value?.role ?? '';

      // Get unread orders based on user role
      QuerySnapshot unreadOrders;
      if (role == 'Customer') {
        unreadOrders = await _firestore
            .collection('orders')
            .where('userId', isEqualTo: currentUser.uid)
            .where('isRead', isEqualTo: false)
            .get();
      } else {
        unreadOrders = await _firestore
            .collection('orders')
            .where('sellerIds', arrayContains: currentUser.uid)
            .where('isRead', isEqualTo: false)
            .get();
      }

      // Mark orders as read
      for (var doc in unreadOrders.docs) {
        batch.update(doc.reference, {
          'isRead': true,
          'lastReadTime': FieldValue.serverTimestamp(),
        });
      }

      // Mark notifications as read
      QuerySnapshot notificationsDocs = await _firestore
          .collection('notifications')
          .where('type', isEqualTo: 'order')
          .where('userId', isEqualTo: currentUser.uid)
          .where('read', isEqualTo: false)
          .get();

      for (var doc in notificationsDocs.docs) {
        batch.update(doc.reference, {'read': true});
      }

      await batch.commit();

      // Update local notification count
      await notificationService.updateUnreadOrderCount();
    } catch (e) {
      print('Error marking orders as read: $e');
    }
  }

  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    try {
      isProcessing.value = true;

      // Get the current order data
      DocumentSnapshot orderDoc = await _firestore
          .collection('orders')
          .doc(orderId)
          .get();

      if (!orderDoc.exists) {
        throw Exception('Order not found');
      }

      Map<String, dynamic> orderData = orderDoc.data() as Map<String, dynamic>;
      
      WriteBatch batch = _firestore.batch();

      // Update the order status
      batch.update(_firestore.collection('orders').doc(orderId), {
        'status': newStatus,
        'lastUpdated': FieldValue.serverTimestamp(),
        'isRead': false,  // Mark as unread when status changes
      });

      // Create notification for the customer
      DocumentReference notificationRef = _firestore.collection('notifications').doc();
      batch.set(notificationRef, {
        'type': 'order',
        'orderId': orderId,
        'userId': orderData['userId'],
        'title': 'Order Update',
        'body': newStatus.toLowerCase() == 'shipped' 
            ? 'Your order #$orderId has been shipped. Rider will arrive within 30 minutes.'
            : 'Your order #$orderId is now $newStatus',
        'timestamp': FieldValue.serverTimestamp(),
        'read': false,
      });

      await batch.commit();

      // Show success message
      Get.snackbar(
        'Success',
        'Order status updated to ${newStatus.capitalizeFirst}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // Trigger notification count update
      await notificationService.updateUnreadOrderCount();
      
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

  @override
  void onClose() {
    activeOrders.clear();
    pastOrders.clear();
    super.onClose();
  }
}