import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farmlink/controllers/LoginController.dart';
import 'package:farmlink/controllers/ProductController.dart';
import 'package:farmlink/models/Cart.dart';
import 'package:farmlink/models/LocalProduce.dart';
import 'package:farmlink/models/UserModel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CartController extends GetxController{

  final productController = Get.find<ProductController>();
  
  //reactive cart object
  var cart = Cart(
    cid: 'cid',
    produces: [],
    quantity: {},
    discount: 0.0,
    status: 'active',
    timestamp: DateTime.now(),
  ).obs;

  final cartRef = FirebaseFirestore.instance.collection('carts');
  final produceRef = FirebaseFirestore.instance.collection('localProduce');
  final orderRef = FirebaseFirestore.instance.collection('orders');

  @override
  void onInit() {
    super.onInit();
    //createCart();
  }

  // Create Cart if it does not exist for the user
   Future<void> createCart() async {
    try {
      // Fetch the current user dynamically
      User? currentUser = FirebaseAuth.instance.currentUser;

      // Check if the user is logged in
      if (currentUser == null) {
        Get.snackbar('Error', 'No user is currently logged in');
        return;
      }

      String uid = currentUser.uid; // Get the user's unique ID

      // Check if the cart already exists for the user
      final cartDoc = await cartRef.doc(uid).get();

      if (cartDoc.exists) {
        cart.value = Cart.fromJson(cartDoc.data()!);
      } else {
        Cart newCart = Cart(
          cid: uid, // Use user ID as the Cart ID
          produces: [], // Empty list of produces
          quantity: {}, // Empty quantity map
          discount: 0.0, // No discount initially
          status: 'active', // Default status is active
          timestamp: DateTime.now(), // Set the current timestamp
        );
        // Save the cart to Firestore using the toJson() method
        await cartRef.doc(uid).set(newCart.toJson());
        cart.value = newCart;
      }
      } catch(e) {
        print('Error initializing cart: $e');
        Get.snackbar('Error', 'Failed to initialize cart');
      }
    } 


  //add produce to cart
  Future<void> addProduceToCart(LocalProduce produce) async {
  try {
    // Ensure user is logged in
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      Get.snackbar('Error', 'No user is currently logged in');
      return;
    }
    // String uid = currentUser.uid;
    if (produce.pid == null || produce.pid!.isEmpty) { 
      Get.snackbar('Error', 'Invalid pid');
      return;
    }

    print('Adding product with pid: ${produce.pid} to cart.');

    if (produce.stock == 0) {
      Get.snackbar('Out of stock', 'Produce is out of stock');
      return;
    }

    // Start a Firestore transaction to ensure consistency and avoid race conditions
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      // Refetch the produce document to get the latest data
      final produceDoc = await transaction.get(produceRef.doc(produce.pid));
      print('Attempting to fetch produce with pid: ${produce.pid}');

      if (!produceDoc.exists) {
        throw Exception('Produces not found');
      }

      //log document data
      print('Document data: ${produceDoc.data()}');

      // Get the current stock from the document
      final currentStock = produceDoc['stock'];
      final currentStatus = produceDoc['status'];

      // Check if stock is sufficient
      if (currentStock == 0) {
        throw Exception('Produce is out of stock');
      }

      // Check if the cart already contains the product
      if (cart.value.quantity.containsKey(produce.pid)) {
        print('Cart quantity for ${produce.pid}: ${cart.value.quantity[produce.pid]}');
        print('Available stock for ${produce.pid}: $currentStock');
        if (currentStock>0) {
          // Update quantity in the cart if stock is available
          cart.value.quantity[produce.pid] = cart.value.quantity[produce.pid]! + 1;
        } else {
          // Handle insufficient stock in the cart
          throw Exception('Cannot add more quantity of this produce to the cart');
        }
      } else {
        // Add produce to cart and set quantity to 1
        cart.value.produces.add(produce);
        cart.value.quantity[produce.pid] = 1;
      }

      // Decrease stock in local produce and update status if stock is zero
      int updatedStock = currentStock - 1;
      String updatedStatus = updatedStock == 0 ? 'out of stock' : currentStatus;

      // Set timestamp for cart expiration check
      cart.value.timestamp = DateTime.now();

      // Update the produce document in Firestore with the new stock and status
      transaction.update(produceRef.doc(produce.pid), {
        'stock': updatedStock,
        'status': updatedStatus,
      });

      // Use addPostFrameCallback to update stock after the build phase
      WidgetsBinding.instance.addPostFrameCallback((_) {
        //update stock in product controller to reflect real-time in ui
      productController.stock.value = updatedStock;
      });

      //refresh cart to trigger ui update
      cart.refresh();

      //cart expiration logic
      final expirationTime = cart.value.timestamp.add(Duration(hours: 24)); // 24-hour expiration
      final currentTime = DateTime.now();

      if (currentTime.isAfter(expirationTime)) {
        // Cart expired, release stock back to inventory and reset cart
        for (var pid in cart.value.quantity.keys) {
          final expiredProduce = cart.value.produces.firstWhere((prod) => prod.pid == pid);
          expiredProduce.stock += cart.value.quantity[pid]!; // Increase stock
          expiredProduce.status = 'available'; // Update status back to available

          // Update Firestore with the released stock
          transaction.update(produceRef.doc(expiredProduce.pid), {
            'stock': expiredProduce.stock,
            'status': expiredProduce.status,
          });
        }

        // Clear expired cart items
        cart.value.produces.clear();
        cart.value.quantity.clear();
      }

      // update the cart's timestamp and other necessary fields in Firestore if needed
      await FirebaseFirestore.instance.collection('carts').doc(cart.value.cid).update({
        'timestamp': cart.value.timestamp,
        'produces': cart.value.produces.map((e) => e.toJson()).toList(),
        'quantity': cart.value.quantity,
        'discount': cart.value.discount,
        'status': cart.value.status,
      });
    });
    Get.snackbar('Success', 'Product added to the cart');
  } catch (e) {
    Get.snackbar('Error', e.toString());
    print('Error adding produce to cart: $e');
  }
}

Future<void> removeProduceFromCart(LocalProduce produce) async {
  try{
    if (produce.pid == null || produce.pid!.isEmpty){
      return;
    }
    print('Removing produce with pid: ${produce.pid} from cart');

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      //refetch to get latest data
      final produceDoc = await transaction.get(produceRef.doc(produce.pid));
      print('Attempting to fetch produce with pid: ${produce.pid}');

      if (!produceDoc.exists) {
        throw Exception('Produce not found');
      }

      print('Document data: ${produceDoc.data()}');

      final currentStock = produceDoc['stock'];
      final currentStatus = produceDoc['status'];

      if(!cart.value.quantity.containsKey(produce.pid)) {
        throw Exception('Produce not found in cart');
      }

      //get quantity of produce in cart based on pid
      var cartQuantity = cart.value.quantity[produce.pid]!;

      //remove produce from cart
      cart.value.produces.removeWhere((prod) => prod.pid == produce.pid);
      cart.value.quantity.remove(produce.pid);

      //add back to stock
      int updatedStock = currentStock + cartQuantity;
      String updatedStatus = updatedStock == 0 ? 'out of stock' : currentStatus;

      transaction.update(produceRef.doc(produce.pid), {
        'stock': updatedStock,
        'status': updatedStatus,
      });

      WidgetsBinding.instance.addPostFrameCallback((_){
        productController.stock.value = updatedStock;
      });

      cart.refresh();
      await FirebaseFirestore.instance.collection('carts').doc(cart.value.cid).update({
        'timestamp': cart.value.timestamp,
        'produces': cart.value.produces.map((e) => e.toJson()).toList(),
        'quantity': cart.value.quantity,
        'discount': cart.value.discount,
        'status': cart.value.status,
      });


    });

    Get.snackbar('Success', 'Produce removed from cart');
  } catch(e){
    print('Error removing produce from cart: $e');
  }
}

Future<void> removeOneProduceFromCart(LocalProduce produce) async {
  try{
    if (produce.pid == null || produce.pid!.isEmpty){
      return;
    }
    print('Removing produce with pid: ${produce.pid} from cart');

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      //refetch to get latest data
      final produceDoc = await transaction.get(produceRef.doc(produce.pid));
      print('Attempting to fetch produce with pid: ${produce.pid}');

      if (!produceDoc.exists) {
        throw Exception('Produce not found');
      }

      print('Document data: ${produceDoc.data()}');

      final currentStock = produceDoc['stock'];
      final currentStatus = produceDoc['status'];

      if(!cart.value.quantity.containsKey(produce.pid)) {
        throw Exception('Produce not found in cart');
      }

      //get quantity of produce in cart based on pid
      var cartQuantity = cart.value.quantity[produce.pid]!;

      if(cartQuantity == 1) {
        //remove produce from cart
        cart.value.produces.removeWhere((prod) => prod.pid == produce.pid);
        cart.value.quantity.remove(produce.pid);
      } else {
        cart.value.quantity[produce.pid] = cartQuantity - 1;
      }

      //add back to stock
      int updatedStock = currentStock + cartQuantity;
      String updatedStatus = updatedStock == 0 ? 'out of stock' : currentStatus;

      transaction.update(produceRef.doc(produce.pid), {
        'stock': updatedStock,
        'status': updatedStatus,
      });

      WidgetsBinding.instance.addPostFrameCallback((_){
        productController.stock.value = updatedStock;
      });

      cart.refresh();
      await FirebaseFirestore.instance.collection('carts').doc(cart.value.cid).update({
        'timestamp': cart.value.timestamp,
        'produces': cart.value.produces.map((e) => e.toJson()).toList(),
        'quantity': cart.value.quantity,
        'discount': cart.value.discount,
        'status': cart.value.status,
      });


    });

    Get.snackbar('Success', 'Produce removed from cart');
  } catch(e){
    print('Error removing produce from cart: $e');
  }
}

  double calculatePriceForEachProduce(LocalProduce produce){
    int quantityForEachProduce = cart.value.quantity[produce.pid] ?? 0;
    return produce.price * quantityForEachProduce;
  }

  double calculateTotalPrice() {
    double totalPrice = 0;
    cart.value.produces.forEach((produce) {
      totalPrice += calculatePriceForEachProduce(produce);
    });
    return totalPrice;
  }

  Future<void> createAddress() async{
     try {
      // Fetch the current user dynamically
      User? currentUser = FirebaseAuth.instance.currentUser;

      // Check if the user is logged in
      if (currentUser == null) {
        Get.snackbar('Error', 'No user is currently logged in');
        return;
      }

      String uid = currentUser.uid; // Get the user's unique ID

      // Check if the cart already exists for the user
      final cartDoc = await cartRef.doc(uid).get();

      if (cartDoc.exists) {
        cart.value = Cart.fromJson(cartDoc.data()!);
      } else {
        Cart newCart = Cart(
          cid: uid, // Use user ID as the Cart ID
          produces: [], // Empty list of produces
          quantity: {}, // Empty quantity map
          discount: 0.0, // No discount initially
          status: 'active', // Default status is active
          timestamp: DateTime.now(), // Set the current timestamp
        );
        // Save the cart to Firestore using the toJson() method
        await cartRef.doc(uid).set(newCart.toJson());
        cart.value = newCart;
      }
      } catch(e) {
        print('Error initializing cart: $e');
        Get.snackbar('Error', 'Failed to initialize cart');
      }
  }

  Future<void> clearCart() async {
  // Clear the cart data
  if (cart.value.cid.isEmpty) {
    print('Error: Cart ID is empty');
    return; // Prevent operation if cart ID is not valid
  }
  // cart.value = Cart(
  //   cid: '',
  //   produces: [],
  //   quantity: {},
  //   discount: 0.0,
  //   status: 'inactive',
  //   timestamp: DateTime.now(),
  // );
  
  // Optionally, clear the cart in Firestore or update the UI accordingly
  await FirebaseFirestore.instance.collection('carts').doc(cart.value.cid).update({
    'produces': [],
    'quantity': {},
    'discount': 0.0,
    'status': 'inactive',
    'timestamp': DateTime.now(),
  });

  // Optionally, notify the user about cart reset
  Get.snackbar('Cart Reset', 'Your cart has been cleared.');
}
  // Future<void> checkout() async{
  //   final orderRef = FirebaseFirestore.instance.collection('orders');
  // }

}