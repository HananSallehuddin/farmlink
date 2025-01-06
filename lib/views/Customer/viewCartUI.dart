import 'dart:convert';

import 'package:farmlink/styles.dart';
import 'package:flutter/material.dart';
import 'package:farmlink/controllers/CartController.dart';
import 'package:get/get.dart';

class viewCartUI extends StatelessWidget {
  final CartController cartController = Get.find<CartController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        title: Text('Shopping Cart'),
      ),
      body: Obx(() {
        // Display the cart items
        if (cartController.cart.value?.produces?.isEmpty ?? true) {
          return Center(child: Text('Your cart is empty.'));
        }

        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: cartController.cart.value.produces.length,
                itemBuilder: (context, index) {
                  var produce = cartController.cart.value.produces[index];
                  var quantity = cartController.cart.value.quantity[produce.pid] ?? 0;

                  return Dismissible(
                    key: Key(produce.pid), // Unique key for each item
                    direction: DismissDirection.startToEnd, // Swipe left-to-right only
                    background: Container(
                      padding: EdgeInsets.only(left: 20),
                      color: Colors.red, // Background color for swipe
                      alignment: Alignment.centerLeft,
                      child: Icon(
                        Icons.delete,  
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                    onDismissed: (direction) {
                      // Remove item from the cart
                      cartController.removeProduceFromCart(produce);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Image
                          ClipRRect(
                            borderRadius: BorderRadius.circular(30),
                            child: SizedBox.fromSize(
                              size: Size.fromRadius(80),
                              child: Image.network(
                                produce.imageUrls[0],
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          // Product details
                          Flexible(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  produce.productName,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  '\RM${produce.price.toStringAsFixed(2)} x $quantity',
                                  style: TextStyle(fontSize: 20, color: Colors.black54),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.remove, color: Colors.black),
                                      onPressed: () {
                                        cartController.removeOneProduceFromCart(produce);
                                      },
                                    ),
                                    Text('$quantity'),
                                    IconButton(
                                      icon: Icon(Icons.add, color: Colors.black),
                                      onPressed: () {
                                        cartController.addProduceToCart(produce);
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            // Total Price and Checkout Button
            Container(
              padding: EdgeInsets.all(30.0),
              //color: Colors.white,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'Total:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                        Obx(() {
                        double totalPrice = cartController.calculateTotalPrice();
                        return Text(
                        'RM${totalPrice.toStringAsFixed(2)}',
                        style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                            ),
                          );
                        }),
                    ],
                  ),
                  SizedBox(height: 20),

                Center(
                  child: ElevatedButton(
                    onPressed: () {
                        Get.toNamed('checkout');
                      },
                    child: Text(
                      'Checkout',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Styles.primaryColor,  // Set the button color
                      padding: EdgeInsets.symmetric(
                        horizontal: 32, vertical: 12
                      ),
                      textStyle: TextStyle(fontSize: 20, color: Colors.black),
                    ),
                  ),
                ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }
}