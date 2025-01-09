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


@override
void onInit() {
super.onInit();
User? currentUser = FirebaseAuth.instance.currentUser;
if (currentUser != null) {
currentUID = currentUser.uid;
print(currentUID);
} else {
Get.snackbar('Error', 'User not authenticated');
return;
}
}


Future<void> createOrder(double totalPrice, DocumentReference addressRef) async {
try{
final currentUserDoc = FirebaseFirestore.instance.collection('users').doc(currentUID);
final userSnapshot = await currentUserDoc.get();


if (addressRef == null) {
print('No address found for the user');
return;
}
final List<LocalProduce> produceList = cartController.cart.value.produces;
final oid = FirebaseFirestore.instance.collection('orders').doc().id;


final newOrder = FarmLinkOrder.Order(
oid: oid,
produces: produceList,
totalPrice: totalPrice,
orderDate: DateTime.now(),
addressRef: addressRef,
);


await FirebaseFirestore.instance
.collection('orders')
.doc(currentUID)
.collection('custOrders')
.add(newOrder.toJson());


for (var produce in produceList) {
var sellerRef = produce.userRef;
// Save the order under the seller's collection
await FirebaseFirestore.instance
.collection('users')
.doc(sellerRef!.id)
.collection('sellerOrders')
.add(newOrder.toJson());
print('Order successfully added to sellerOrders for seller: ${sellerRef.id}');


// Send notification to seller
// await FirebaseFirestore.instance
// .collection('users')
// .doc(sellerRef.id)
// .collection('notifications')
// .add({
// 'message': 'You have a new order',
// 'timestamp': FieldValue.serverTimestamp(),
// });
}
// Clear the cart
cartController.cart.value.produces.clear(); // Clear the product list
cartController.cart.value.quantity.clear(); // Clear the quantity map
cartController.cart.value.discount = 0.0; // Reset discount
cartController.cart.value.status = 'active'; // Reset status to active
cartController.cart.value.timestamp = DateTime.now();
print('Order placed successfully');
} catch (e){
print('Error placing order: $e');
}
}


//fetch order for that customer
Future<void> fetchCustomerOrders() async {
try{
final querySnapshot = await FirebaseFirestore.instance.collection('orders')
.doc(currentUID)
.collection('custOrders')
.get();
final List<FarmLinkOrder.Order> orders = querySnapshot.docs.map((doc) {
return FarmLinkOrder.Order.fromJson({
...doc.data(),
'oid': doc.id, // Include the Firestore document ID
});
}).toList();
customerOrders.assignAll(orders);


print('Fetched order for customer: $customerOrders');
} catch(e) {
print('Error fetching order for customer: $e' );
}
}


//fecth order for that seller
Future<void> fetchSellerOrders() async {
try {
// Fetch all customer orders where the seller is the current user
final querySnapshot = await FirebaseFirestore.instance
.doc(currentUID)
.collection('sellerOrders')
.get();


// Map the orders data to a list of orders
final List<FarmLinkOrder.Order> orders = querySnapshot.docs.map((doc) {
return FarmLinkOrder.Order.fromJson({
...doc.data(),
'oid': doc.id, // Add the document ID as the order ID
});
}).toList();
sellerOrders.assignAll(orders);


print('Fetched orders for seller: $sellerOrders');
} catch (e) {
print('Error fetching orders for seller: $e');
}
}


// Update order status
Future<void> updateOrderStatus(String orderId, String newStatus) async {
try {
await FirebaseFirestore.instance.collection('orders')
.doc(currentUID)
.collection('userOrders')
.doc(orderId)
.update({'status': newStatus});
status.value = newStatus; // Update the reactive variable
print('Order status updated successfully');
} catch (e) {
print('Error updating order status: $e');
}
}






}
