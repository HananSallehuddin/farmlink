import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farmlink/controllers/CartController.dart';
import 'package:farmlink/controllers/UserController.dart';
import 'package:farmlink/models/LocalProduce.dart';
import 'package:farmlink/models/UserModel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:farmlink/models/Order.dart' as FarmLinkOrder;

class OrderController extends GetxController {
  var customerOrders = <FarmLinkOrder.Order>[].obs;
  var sellerOrders = <FarmLinkOrder.Order>[].obs;
  var status = ''.obs;
  final cartController = Get.find<CartController>();
  final userController = Get.find<UserController>();
  var selectedOrder = Rxn<FarmLinkOrder.Order>();

  @override
  void onInit() {
    super.onInit();
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        print('User signed in: ${user.uid}');
      } else {
        print('User not authenticated');
        Get.snackbar('Error', 'Please sign in to manage your orders.');
      }
    });
  }

  Future<void> createOrder(double totalPrice, DocumentReference addressRef) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('User not authenticated');
        Get.snackbar('Error', 'Please sign in to place an order.');
        return;
      }

      final currentUID = user.uid;
      final currentUserDoc = FirebaseFirestore.instance.collection('users').doc(currentUID);
      final userSnapshot = await currentUserDoc.get();

      if (addressRef == null) {
        print('No address found for the user');
        return;
      }

      final List<LocalProduce> produceList = cartController.cart.value.produces;
      Map<String, int> quantitiesMap = cartController.cart.value.quantity;

      final oid = FirebaseFirestore.instance.collection('orders').doc().id;

      final newOrder = FarmLinkOrder.Order(
        oid: oid,
        produces: produceList,
        totalPrice: totalPrice,
        quantities: quantitiesMap,
        orderDate: DateTime.now(),
        addressRef: addressRef,
        customerRef: currentUserDoc,
      );

      await FirebaseFirestore.instance
          .collection('orders')
          .doc(oid)
          .set(newOrder.toJson());

      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUID)
          .collection('custOrders')
          .doc(oid)
          .set(newOrder.toJson());

      for (var produce in produceList) {
        var sellerRef = produce.userRef;
        if (sellerRef != null) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(sellerRef.id)
              .collection('sellerOrders')
              .doc(oid)
              .set(newOrder.toJson());
          print('Order successfully added to sellerOrders for seller: ${sellerRef.id}');
        }
      }

      cartController.cart.value.produces.clear();
      cartController.cart.value.quantity.clear();
      cartController.cart.value.discount = 0.0;
      cartController.cart.value.status = 'active';
      cartController.cart.value.timestamp = DateTime.now();
      cartController.cart.refresh();

      print('Order placed successfully');
    } catch (e) {
      print('Error placing order: $e');
    }
  }

  Future<void> fetchCustomerOrders() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('User not authenticated');
        Get.snackbar('Error', 'Please sign in to fetch orders.');
        return;
      }

      final currentUID = user.uid;

      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUID)
          .collection('custOrders')
          .get();

      final List<FarmLinkOrder.Order> orders = querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final addressRef = data['addressRef'];
        final customerRef = data['customerRef'];

        return FarmLinkOrder.Order.fromJson({
          ...data,
          'oid': doc.id,
          'addressRef': addressRef ?? '',
          'customerRef': customerRef ?? '',
        });
      }).toList();

      customerOrders.assignAll(orders);
      print('Fetched orders for customer: $customerOrders');
    } catch (e) {
      print('Error fetching orders for customer: $e');
    }
  }

  Future<void> fetchSellerOrders() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('User not authenticated');
        Get.snackbar('Error', 'Please sign in to fetch orders.');
        return;
      }

      final currentUID = user.uid;

      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUID)
          .collection('sellerOrders')
          .get();

      final List<FarmLinkOrder.Order> orders = querySnapshot.docs.map((doc) {
        final data = doc.data();
        final addressRef = data['addressRef'];
        final customerRef = data['customerRef'];

        return FarmLinkOrder.Order.fromJson({
          ...data,
          'oid': doc.id,
          'addressRef': addressRef,
          'customerRef': customerRef,
        });
      }).toList();

      sellerOrders.assignAll(orders);
      print('Fetched orders for seller: $sellerOrders');
    } catch (e) {
      print('Error fetching orders for seller: $e');
    }
  }

  Future<void> updateOrderStatus(String newStatus) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('User not authenticated');
        Get.snackbar('Error', 'Please sign in to update the order status.');
        return;
      }

      final currentUID = user.uid;

      if (selectedOrder.value == null) {
        print('No order selected for updating status');
        return;
      }

      final order = selectedOrder.value!;
      final oid = order.oid;
      final sellerRef = order.produces.first.userRef;

      if (sellerRef != null) {
        await FirebaseFirestore.instance.collection('users')
            .doc(sellerRef.id)
            .collection('sellerOrders')
            .doc(oid)
            .update({'status': newStatus});
      }

      await fetchSellerOrders();
      selectedOrder.value!.status = newStatus;
      status.value = newStatus;
      selectedOrder.refresh();
      print('Order status updated successfully to $newStatus');
    } catch (e) {
      print('Error updating order status: $e');
    }
  }

  Future<void> sendNotificationToSeller(FarmLinkOrder.Order order) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('User not authenticated');
        Get.snackbar('Error', 'Please sign in to send notification.');
        return;
      }

      final currentUID = user.uid;
      final sellerRef = order.produces.first.userRef;

      if (sellerRef != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(sellerRef.id)
            .collection('notifications')
            .add({
          'message': 'You have a new order',
          'timestamp': FieldValue.serverTimestamp(),
        });

        print('Notification sent to seller: ${sellerRef.id}');
      } else {
        print('Seller reference is null, cannot send notification.');
      }
    } catch (e) {
      print('Error sending notification to seller: $e');
    }
  }
}