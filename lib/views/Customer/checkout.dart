import 'dart:convert';

import 'package:farmlink/controllers/CartController.dart';
import 'package:farmlink/controllers/UserController.dart';
import 'package:farmlink/models/LocalProduce.dart';
import 'package:farmlink/styles.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class checkoutUI extends StatelessWidget {
  const checkoutUI({super.key});

  @override
  Widget build(BuildContext context) {
    final userController = Get.find<UserController>();
    final cartController = Get.find<CartController>();
    final String currentUID = FirebaseAuth.instance.currentUser!.uid;

    final List<LocalProduce> produceList = cartController.cart.value.produces; // Directly access produces
    final double totalPrice = cartController.calculateTotalPrice(); // Calculate total price using CartController

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        title: const Text('Checkout'),
      ),
      body: Obx(() {
        var selectedAddress = userController.selectedAddress.value;

        // Check if the address is selected, otherwise show an option to add a new address
        if (selectedAddress == null) {
          return Center(
            child: ElevatedButton(
              onPressed: () {
                Get.toNamed('addressList');
              },
              child: const Text('Add new address'),
            ),
          );
        }

        // If an address is selected, display it with a border and filling the row
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Delivery Address:', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: (){
                  Get.toNamed('addressList');
                },
                child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Styles.primaryColor, // Light blue background for selected address
                  border: Border.all(color: Colors.green.shade50, width: 2), // Blue border for selected address
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            selectedAddress.address,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 6),
                          Text('${selectedAddress.city}, ${selectedAddress.state}, ${selectedAddress.zipCode}'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              ),
              const SizedBox(height: 20),
              // Display produces
              Text('Produces to buy:', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 10),

              Expanded(
                child: ListView.builder(
                  itemCount: produceList.length,
                  itemBuilder: (context, index) {
                    final product = produceList[index];
                    return ListTile(
                      title: Text(product.productName),
                      subtitle: Text('${product.price.toStringAsFixed(2)}'),
                    );
                  },
                ),
              ),
              // Display total price
              Text('Total Price: \RM${totalPrice.toStringAsFixed(2)}', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 20),
              Text('Payment Method: Cash On Delivery', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: (){
                  //confirm order method
                }, 
                child: Text(  
                  'Confirm order'
                ),
                ),
                const SizedBox(height: 20),
            ],
          ),
        );
      }),
    );
  }
}