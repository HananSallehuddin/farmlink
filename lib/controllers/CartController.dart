import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farmlink/controllers/ProductController.dart';
import 'package:farmlink/models/Cart.dart';
import 'package:farmlink/models/LocalProduce.dart';
import 'package:farmlink/models/UserModel.dart';
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

  var selectedAddress = Rxn<Address>();
  var isAnyLoading = false.obs;
  var isProcessing = false.obs;

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
        cart.value = Cart(
          cid: 'cid',
          produces: [],
          quantity: {},
          discount: 0.0,
          status: 'active',
          timestamp: DateTime.now(),
        );
        selectedAddress.value = null;
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

      isAnyLoading.value = true;

      await _firestore.runTransaction((transaction) async {
        final produceDoc = await transaction.get(
          _firestore.collection('localProduce').doc(produce.pid)
        );

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
          } else {
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

        transaction.update(
          _firestore.collection('localProduce').doc(produce.pid),
          {
            'stock': updatedStock,
            'status': updatedStatus,
          }
        );

        await _firestore.collection('carts').doc(cart.value.cid).update(cart.value.toJson());
      });

      cart.refresh();
      //Get.snackbar('Success', 'Product added to cart');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isAnyLoading.value = false;
    }
  }

  Future<void> removeOneProduceFromCart(LocalProduce produce) async {
    try {
      if (produce.pid.isEmpty || !cart.value.quantity.containsKey(produce.pid)) {
        return;
      }

      isAnyLoading.value = true;

      await _firestore.runTransaction((transaction) async {
        final produceDoc = await transaction.get(
          _firestore.collection('localProduce').doc(produce.pid)
        );

        if (!produceDoc.exists) {
          throw Exception('Product not found');
        }

        int currentQuantity = cart.value.quantity[produce.pid] ?? 0;
        if (currentQuantity <= 1) {
          await removeProduceFromCart(produce);
          return;
        }

        cart.value.quantity[produce.pid] = currentQuantity - 1;

        int currentStock = produceDoc.data()!['stock'] as int;
        transaction.update(
          _firestore.collection('localProduce').doc(produce.pid),
          {
            'stock': currentStock + 1,
            'status': currentStock + 1 > 0 ? 'available' : 'out of stock',
          }
        );

        cart.value.calculateTotalAmount();
        await _firestore.collection('carts').doc(cart.value.cid).update(cart.value.toJson());
      });

      cart.refresh();
      //Get.snackbar('Success', 'Product quantity updated');
    } catch (e) {
      print('Error updating product quantity: $e');
      Get.snackbar('Error', 'Failed to update product quantity');
    } finally {
      isAnyLoading.value = false;
    }
  }

  Future<void> removeProduceFromCart(LocalProduce produce) async {
    try {
      if (produce.pid.isEmpty) return;
      isAnyLoading.value = true;

      await _firestore.runTransaction((transaction) async {
        final produceDoc = await transaction.get(
          _firestore.collection('localProduce').doc(produce.pid)
        );

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

        transaction.update(
          _firestore.collection('localProduce').doc(produce.pid),
          {
            'stock': updatedStock,
            'status': updatedStock > 0 ? 'available' : 'out of stock',
          }
        );

        cart.value.calculateTotalAmount();
        await _firestore.collection('carts').doc(cart.value.cid).update(cart.value.toJson());
      });

      cart.refresh();
      //Get.snackbar('Success', 'Product removed from cart');
    } catch(e) {
      print('Error removing produce from cart: $e');
      Get.snackbar('Error', 'Failed to remove product from cart');
    } finally {
      isAnyLoading.value = false;
    }
  }

  Future<void> updateCartAddress(Address address) async {
    try {
      if (address.address.isEmpty) {
        throw Exception('Address cannot be empty');
      }

      isAnyLoading.value = true;

      String fullAddress = '${address.address}, ${address.city}, ${address.state} ${address.zipCode}';

      cart.update((val) {
        val?.shippingAddress = fullAddress;
      });

      selectedAddress.value = address;

      await _firestore.collection('carts').doc(cart.value.cid).update({
        'shippingAddress': fullAddress,
      });

      cart.refresh();
      //Get.snackbar('Success', 'Shipping address updated');
    } catch (e) {
      print('Error updating cart address: $e');
      Get.snackbar('Error', 'Failed to update shipping address');
      rethrow;
    } finally {
      isAnyLoading.value = false;
    }
  }

  Future<void> processCheckout() async {
    try {
      if (cart.value.produces.isEmpty) {
        throw Exception('Cart is empty');
      }
      if (selectedAddress.value == null) {
        throw Exception('Please select a shipping address');
      }

      isProcessing.value = true;
      final cartDoc = await _firestore.collection('carts').doc(cart.value.cid).get();
      if (!cartDoc.exists) {
        throw Exception('Cart not found');
      }

      await _firestore.runTransaction((transaction) async {
        DocumentReference orderRef = _firestore.collection('orders').doc();
        List<Map<String, dynamic>> verifiedProducts = [];
        Set<String> sellerIds = {};

        // Group products by seller
        Map<String, List<Map<String, dynamic>>> productsBySeller = {};

        for (var produce in cart.value.produces) {
          if (produce.userRef == null) continue;

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

          Map<String, dynamic> verifiedProduct = {
            ...productData,
            'pid': produce.pid,
            'sellerId': sellerId,
            'quantity': requestedQuantity,
            'userRef': produce.userRef,
            'subtotal': produce.price * requestedQuantity
          };

          verifiedProducts.add(verifiedProduct);

          // Group products by seller for notifications
          if (!productsBySeller.containsKey(sellerId)) {
            productsBySeller[sellerId] = [];
          }
          productsBySeller[sellerId]!.add(verifiedProduct);

          transaction.update(
            _firestore.collection('localProduce').doc(produce.pid),
            {
              'stock': currentStock - requestedQuantity,
              'status': (currentStock - requestedQuantity) > 0 ? 'available' : 'out of stock'
            }
          );
        }

        String fullAddress = '${selectedAddress.value!.address}, ${selectedAddress.value!.city}, ${selectedAddress.value!.state} ${selectedAddress.value!.zipCode}';

        Map<String, dynamic> orderData = {
          'orderId': orderRef.id,
          'userId': cart.value.cid,
          'products': verifiedProducts,
          'quantities': cart.value.quantity,
          'totalAmount': cart.value.totalAmount,
          'shippingAddress': fullAddress,
          'status': 'pending',
          'paymentMethod': cart.value.paymentMethod,
          'orderDate': FieldValue.serverTimestamp(),
          'lastUpdated': FieldValue.serverTimestamp(),
          'sellerIds': sellerIds.toList(),
        };

        transaction.set(orderRef, orderData);
        transaction.delete(_firestore.collection('carts').doc(cart.value.cid));

        // Create notifications for each seller
        for (var sellerId in productsBySeller.keys) {
          var sellerProducts = productsBySeller[sellerId]!;
          double sellerTotal = sellerProducts.fold(0.0, (sum, product) => 
            sum + (product['subtotal'] as double));

          DocumentReference notificationRef = _firestore.collection('notifications').doc();
          transaction.set(notificationRef, {
            'type': 'order',
            'orderId': orderRef.id,
            'userId': sellerId, // Set seller as the notification recipient
            'title': 'New Order',
            'body': 'New order received for ${sellerProducts.length} item(s), total: RM${sellerTotal.toStringAsFixed(2)}',
            'timestamp': FieldValue.serverTimestamp(),
            'read': false,
          });
        }
      });

      await resetExpiredCart(cart.value.cid);
      selectedAddress.value = null;

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
    } finally {
      isProcessing.value = false;
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