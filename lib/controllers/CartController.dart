import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farmlink/controllers/ProductController.dart';
import 'package:farmlink/models/Cart.dart';
import 'package:farmlink/models/LocalProduce.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CartController extends GetxController {
  final productController = Get.find<ProductController>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  var cart = Cart(
    cid: 'cid',
    produces: [],
    quantity: {},
    discount: 0.0,
    status: 'active',
    timestamp: DateTime.now(),
  ).obs;

  @override
  void onInit() {
    super.onInit();
    _setupCartListener();
  }

  void _setupCartListener() {
    _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        createCart();
      } else {
        // Clear cart when user logs out
        cart.value = Cart(
          cid: 'cid',
          produces: [],
          quantity: {},
          discount: 0.0,
          status: 'active',
          timestamp: DateTime.now(),
        );
      }
    });
  }

  Future<void> createCart() async {
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        Get.snackbar('Error', 'No user is currently logged in');
        return;
      }

      String uid = currentUser.uid;
      final cartDoc = await _firestore.collection('carts').doc(uid).get();

      if (cartDoc.exists) {
        cart.value = Cart.fromJson(cartDoc.data()!);
        // Check for expired cart
        if (cart.value.isExpired()) {
          await resetExpiredCart(uid);
        }
      } else {
        Cart newCart = Cart(
          cid: uid,
          produces: [],
          quantity: {},
          discount: 0.0,
          status: 'active',
          timestamp: DateTime.now(),
        );
        await _firestore.collection('carts').doc(uid).set(newCart.toJson());
        cart.value = newCart;
      }
    } catch(e) {
      print('Error initializing cart: $e');
      //Get.snackbar('Error', 'Failed to initialize cart');
    }
  }

  Future<void> addProduceToCart(LocalProduce produce) async {
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        Get.snackbar('Error', 'No user is currently logged in');
        return;
      }

      if (produce.pid.isEmpty) {
        Get.snackbar('Error', 'Invalid product ID');
        return;
      }

      await _firestore.runTransaction((transaction) async {
        final produceDoc = await transaction.get(_firestore.collection('localProduce').doc(produce.pid));
        
        if (!produceDoc.exists) {
          throw Exception('Product not found');
        }

        final currentStock = produceDoc.data()!['stock'] as int;
        final currentStatus = produceDoc.data()!['status'] as String;

        if (currentStock == 0) {
          throw Exception('Product is out of stock');
        }

        if (cart.value.quantity.containsKey(produce.pid)) {
          if (currentStock > 0) {
            cart.value.quantity[produce.pid] = cart.value.quantity[produce.pid]! + 1;
          } else{
            throw Exception('Cannot add more quantity of this product to the cart');
          }
          
        } else {
          cart.value.produces.add(produce);
          cart.value.quantity[produce.pid] = 1;
        }

        int updatedStock = currentStock - 1;
        String updatedStatus = updatedStock == 0 ? 'out of stock' : currentStatus;

        cart.value.timestamp = DateTime.now();
        cart.value.calculateTotalAmount();

        transaction.update(_firestore.collection('localProduce').doc(produce.pid), {
          'stock': updatedStock,
          'status': updatedStatus,
        });

        await _firestore.collection('carts').doc(cart.value.cid).update(cart.value.toJson());
      });

      cart.refresh();
      Get.snackbar('Success', 'Product added to cart');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  Future<void> removeOneProduceFromCart(LocalProduce produce) async {
    try {
      if (produce.pid.isEmpty || !cart.value.quantity.containsKey(produce.pid)) {
        return;
      }

      await _firestore.runTransaction((transaction) async {
        final produceDoc = await transaction.get(_firestore.collection('localProduce').doc(produce.pid));
        
        if (!produceDoc.exists) {
          throw Exception('Product not found');
        }

        int currentQuantity = cart.value.quantity[produce.pid] ?? 0;
        if (currentQuantity <= 1) {
          // If only one item, remove the product completely
          await removeProduceFromCart(produce);
          return;
        }

        // Decrease quantity by 1
        cart.value.quantity[produce.pid] = currentQuantity - 1;

        // Update stock in product
        int currentStock = produceDoc.data()!['stock'] as int;
        transaction.update(_firestore.collection('localProduce').doc(produce.pid), {
          'stock': currentStock + 1,
          'status': currentStock + 1 > 0 ? 'available' : 'out of stock',
        });

        cart.value.calculateTotalAmount();
        await _firestore.collection('carts').doc(cart.value.cid).update(cart.value.toJson());
      });

      cart.refresh();
      Get.snackbar('Success', 'Product quantity updated');
    } catch (e) {
      print('Error updating product quantity: $e');
      Get.snackbar('Error', 'Failed to update product quantity');
    }
  }

  Future<void> removeProduceFromCart(LocalProduce produce) async {
    try {
      if (produce.pid.isEmpty) return;

      await _firestore.runTransaction((transaction) async {
        final produceDoc = await transaction.get(_firestore.collection('localProduce').doc(produce.pid));
        
        if (!produceDoc.exists) {
          throw Exception('Product not found');
        }

        if (!cart.value.quantity.containsKey(produce.pid)) {
          throw Exception('Product not found in cart');
        }

        var cartQuantity = cart.value.quantity[produce.pid]!;
        int currentStock = produceDoc.data()!['stock'] as int;

        cart.value.produces.removeWhere((prod) => prod.pid == produce.pid);
        cart.value.quantity.remove(produce.pid);

        int updatedStock = currentStock + cartQuantity;
        transaction.update(_firestore.collection('localProduce').doc(produce.pid), {
          'stock': updatedStock,
          'status': updatedStock > 0 ? 'available' : 'out of stock',
        });

        cart.value.calculateTotalAmount();
        await _firestore.collection('carts').doc(cart.value.cid).update(cart.value.toJson());
      });

      cart.refresh();
      Get.snackbar('Success', 'Product removed from cart');
    } catch(e) {
      print('Error removing produce from cart: $e');
      Get.snackbar('Error', 'Failed to remove product from cart');
    }
  }

  Future<void> updateCartAddress(String address) async {
    try {
      if (address.isEmpty) {
        throw Exception('Address cannot be empty');
      }

      // Update local cart
      cart.update((val) {
        val?.shippingAddress = address;
      });

      // Update Firestore
      await _firestore.collection('carts').doc(cart.value.cid).update({
        'shippingAddress': address,
      });

      cart.refresh();
      Get.snackbar('Success', 'Shipping address updated');
    } catch (e) {
      print('Error updating cart address: $e');
      Get.snackbar('Error', 'Failed to update shipping address');
      rethrow;
    }
  }

  Future<void> processCheckout() async {
    try {
      if (cart.value.produces.isEmpty) {
        throw Exception('Cart is empty');
      }

      // Fetch the cart document directly from Firestore
      final cartDoc = await _firestore.collection('carts').doc(cart.value.cid).get();
      if (!cartDoc.exists) {
        throw Exception('Cart not found');
      }

      final cartData = cartDoc.data()!;
      print(cartData);
      final shippingAddress = cartData['shippingAddress'];
      // if (shippingAddress == null || shippingAddress.toString().trim().isEmpty) {
      //   throw Exception('Please add a shipping address');
      // }

      if (shippingAddress == null || shippingAddress['addressLine']?.trim().isEmpty == true) {
  throw Exception('Please add a shipping address');
}

      // Start a transaction
      await _firestore.runTransaction((transaction) async {
        // Create order document reference
        DocumentReference orderRef = _firestore.collection('orders').doc();

        // Verify stock availability and organize products
        List<Map<String, dynamic>> verifiedProducts = [];
        Set<String> sellerIds = {};

        for (var produce in cart.value.produces) {
          if (produce.userRef == null) continue;

          // Get latest product data
          DocumentSnapshot productDoc = await transaction.get(
            _firestore.collection('localProduce').doc(produce.pid)
          );

          if (!productDoc.exists) {
            throw Exception('Product ${produce.productName} no longer exists');
          }

          Map<String, dynamic> productData = productDoc.data() as Map<String, dynamic>;
          int currentStock = productData['stock'] as int;
          int requestedQuantity = cart.value.quantity[produce.pid] ?? 0;

          if (currentStock < requestedQuantity) {
            throw Exception('Insufficient stock for ${produce.productName}');
          }

          String sellerId = produce.userRef!.id;
          sellerIds.add(sellerId);

          // Add verified product data
          Map<String, dynamic> verifiedProduct = {
            ...productData,
            'pid': produce.pid,
            'sellerId': sellerId,
            'quantity': requestedQuantity,
            'userRef': produce.userRef,
            'subtotal': produce.price * requestedQuantity
          };
          verifiedProducts.add(verifiedProduct);

          // Update product stock
          transaction.update(
            _firestore.collection('localProduce').doc(produce.pid),
            {
              'stock': currentStock - requestedQuantity,
              'status': (currentStock - requestedQuantity) > 0 ? 'available' : 'out of stock'
            }
          );
        }

        // Create order data
        Map<String, dynamic> orderData = {
          'orderId': orderRef.id,
          'userId': cart.value.cid,
          'products': verifiedProducts,
          'quantities': cart.value.quantity,
          'totalAmount': cart.value.totalAmount,
          'shippingAddress': shippingAddress,
          'status': 'pending',
          'paymentMethod': cart.value.paymentMethod,
          'orderDate': FieldValue.serverTimestamp(),
          'lastUpdated': FieldValue.serverTimestamp(),
          'sellerIds': sellerIds.toList(), // Store seller IDs in a simple list
        };

        // Set order document
        transaction.set(orderRef, orderData);

        // Delete existing cart
        transaction.delete(_firestore.collection('carts').doc(cart.value.cid));
      });

      // Reset local cart after successful transaction
      await resetExpiredCart(cart.value.cid);
      Get.snackbar('Success', 'Order placed successfully');
      Get.offAllNamed('/orders');
    } catch (e) {
      print('Error processing checkout: $e');
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 3),
      );
    }
  }

  Future<void> resetExpiredCart(String uid) async {
    Cart newCart = Cart(
      cid: uid,
      produces: [],
      quantity: {},
      discount: 0.0,
      status: 'active',
      timestamp: DateTime.now(),
    );
    await _firestore.collection('carts').doc(uid).set(newCart.toJson());
    cart.value = newCart;
  }

  double calculateTotalPrice() {
    cart.value.calculateTotalAmount();
    return cart.value.totalAmount;
  }

  @override
  void onClose() {
    cart.value.clear();
    super.onClose();
  }
}