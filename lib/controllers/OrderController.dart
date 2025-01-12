import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farmlink/controllers/CartController.dart';
import 'package:farmlink/controllers/UserController.dart';
import 'package:farmlink/models/LocalProduce.dart';
import 'package:farmlink/models/UserModel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:farmlink/models/Order.dart' as FarmLinkOrder;

class OrderController extends GetxController {
late String currentUID;
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
      currentUID = user.uid;
      print('User signed in: $currentUID');

    } else {
      print('User not authenticated');
      Get.snackbar('Error', 'Please sign in to manage your orders.');

    }
  });
}


Future<void> createOrder(double totalPrice, DocumentReference addressRef) async {
  try {
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

      await FirebaseFirestore.instance
          .collection('users')
          .doc(sellerRef!.id)
          .collection('sellerOrders')
          .doc(oid)  
          .set(newOrder.toJson());  

      print('Order successfully added to sellerOrders for seller: ${sellerRef.id}');
    }
    print('Before clearing produces: ${cartController.cart.value.produces}');
    print('Before clearing quantity: ${cartController.cart.value.quantity}');
    cartController.cart.value.produces.clear(); 
    cartController.cart.value.quantity.clear();
    cartController.cart.value.discount = 0.0;
    cartController.cart.value.status = 'active';
    cartController.cart.value.timestamp = DateTime.now();
    cartController.cart.refresh();
    print('After clearing produces: ${cartController.cart.value.produces}');
    print('After clearing quantity: ${cartController.cart.value.quantity}');
    print('Order placed successfully');
  } catch (e) {
    print('Error placing order: $e');
  }
}

//fetch order from customer side
Future<void> fetchCustomerOrders() async {
  try {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUID)
        .collection('custOrders')
        .get();

    final List<FarmLinkOrder.Order> orders = querySnapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;

      print('Fetched Order Data: $data');

      final addressRef = data['addressRef'];
      final customerRef = data['customerRef'];

      if (addressRef == null || customerRef == null) {
        print('Warning: Order with ID ${doc.id} has missing addressRef or customerRef');
        return FarmLinkOrder.Order.fromJson({
          ...data,
          'oid': doc.id,
          'addressRef': '', 
          'customerRef': '', 
        });
      }
      return FarmLinkOrder.Order.fromJson({
        ...data,
        'oid': doc.id,
        'addressRef': addressRef,
        'customerRef': customerRef,
      });
    }).toList();

    customerOrders.assignAll(orders);
    print('Fetched orders for customer: $customerOrders');
  } catch (e) {
    print('Error fetching orders for customer: $e');
  }
}


//fetch order from seller side
Future<void> fetchSellerOrders() async {
    try {
      print('Current UID: $currentUID');

      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUID)
          .collection('sellerOrders')
          .get();

      print('Query snapshot fetched: ${querySnapshot.docs.length} orders found');

      final List<FarmLinkOrder.Order> orders = querySnapshot.docs.map((doc) {
        final data = doc.data();
        final addressRef = data['addressRef'];
        final customerRef = data['customerRef'];

        print('addressRef: $addressRef, customerRef: $customerRef');

        if (addressRef == null || customerRef == null) {
          print('Warning: Order with ID ${doc.id} has missing addressRef or customerRef');
        }

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

// Update order status
// Future<void> updateOrderStatus(String newStatus) async {
//   if (selectedOrder.value == null) {
//     print('No order selected for updating status');
//     return;
//   }

//   try {
//     final order = selectedOrder.value!;
//     final oid = order.oid;
//     final sellerRef = order.produces.first.userRef;

//     if (sellerRef != null) {
//       // Fetch the current status from Firestore before updating
//       final orderSnapshot = await FirebaseFirestore.instance
//           .collection('users')
//           .doc(sellerRef.id)
//           .collection('sellerOrders')
//           .doc(oid)
//           .get();

//       final currentStatus = orderSnapshot.data()?['status'] ?? 'Pending';
//       print('Current status: $currentStatus');  // Log current status

//       // Only update status if it's different
//       if (currentStatus != newStatus) {
//         await FirebaseFirestore.instance.collection('users')
//           .doc(sellerRef.id)
//           .collection('sellerOrders')
//           .doc(oid)
//           .update({'status': newStatus});
        
//         print('Order status updated to $newStatus');
//       } else {
//         print('Status is already $currentStatus, no update needed');
//       }
//     }

//     await fetchSellerOrders();  // Refresh the orders list
//     status.value = newStatus;   // Update the status in controller

//   } catch (e) {
//     print('Error updating order status: $e');
//   }
// }
Future<void> updateOrderStatus(String newStatus) async {
  if (selectedOrder.value == null){
    print('No order selected for updating status');
    return;
  }
  try {
    final order = selectedOrder.value!;
    final oid = order.oid;
    final sellerRef = order.produces.first.userRef;

    if(sellerRef != null) {
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
}


// Send notification to seller
// await FirebaseFirestore.instance
// .collection('users')
// .doc(sellerRef.id)
// .collection('notifications')
// .add({
// 'message': 'You have a new order',
// 'timestamp': FieldValue.serverTimestamp(),
// });
