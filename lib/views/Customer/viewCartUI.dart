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
        backgroundColor: Styles.primaryColor,
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
                    key: Key(produce.pid), 
                    direction: DismissDirection.startToEnd, 
                    background: Container(
                      padding: EdgeInsets.only(left: 20),
                      color: Colors.red, 
                      alignment: Alignment.centerLeft,
                      child: Icon(
                        Icons.delete,  
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                    onDismissed: (direction) {
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
            Container(
              padding: EdgeInsets.all(30.0),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,  
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Total Price Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total:',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Obx(() {
                        double totalPrice = cartController.calculateTotalPrice();
                        return Text(
                          'RM${totalPrice.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Styles.primaryColor,
                          ),
                        );
                      }),
                    ],
                  ),
                  SizedBox(height: 20),
                  // Checkout Button
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.toNamed('checkout');
                      },
                      child: Text(
                        'Checkout',
                        //style: TextStyle(fontSize: 20, color: Colors.black),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Styles.primaryColor,
                        padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                        textStyle: TextStyle(fontSize: 20),
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