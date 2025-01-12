import 'dart:convert';

import 'package:farmlink/controllers/CartController.dart';
import 'package:farmlink/controllers/OrderController.dart';
import 'package:farmlink/controllers/UserController.dart';
import 'package:farmlink/models/LocalProduce.dart';
import 'package:farmlink/styles.dart';
//import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:farmlink/models/Order.dart' as FarmLinkOrder;


class checkoutUI extends StatelessWidget {
  const checkoutUI({super.key});

  @override
  Widget build(BuildContext context) {
    final userController = Get.find<UserController>();
    final cartController = Get.find<CartController>();
    final orderController = Get.find<OrderController>();
    //final String currentUID = FirebaseAuth.instance.currentUser!.uid;

    final List<LocalProduce> produceList = cartController.cart.value.produces; 
    final double totalPrice = cartController.calculateTotalPrice();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Styles.primaryColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        title: const Text('Checkout'),
      ),
      body: Obx(() {
        var selectedAddress = userController.selectedAddress.value;

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
                  color: Styles.primaryColor, 
                  border: Border.all(color: Colors.green.shade50, width: 2), 
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
                      contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 0),
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: SizedBox(
                          width: 50, 
                          height: 50, 
                          child: Image.network(
                            product.imageUrls.isNotEmpty ? product.imageUrls[0] : 'default_image_url', 
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      title: Text(product.productName),
                      subtitle: Text('\RM${product.price.toStringAsFixed(2)}'),
                    );
                  },
                ),
              ),
              
              Text('Total Price: \RM${totalPrice.toStringAsFixed(2)}', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 20),
              Text('Payment Method:', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Styles.primaryColor,
                  border: Border.all(color: Colors.green.shade50, width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green),
                    const SizedBox(width: 10),
                    Text(
                      'Cash On Delivery',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200, 
                  border: Border.all(color: Colors.grey, width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.block, color: Colors.grey), 
                    const SizedBox(width: 10),
                    Text(
                      'Credit/Debit Card ',
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    final selectedAddress = userController.selectedAddress.value;

                    print('Selected Address: $selectedAddress');
                    print('Selected Address Reference: ${selectedAddress?.reference}');

                    if (selectedAddress != null && selectedAddress.reference != null) {
        
                      await orderController.createOrder(totalPrice, selectedAddress.reference!);
                      cartController.cart.refresh();
                      Get.snackbar('Order placed', 'Your order has been placed');
                      Get.offAllNamed('/homepageCustomer');
                    } else {
                      Get.snackbar('Error', 'Please select a valid address');
                    }
                  },
                  child: Text(
                    'Confirm Order',
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Styles.primaryColor,  
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    
                  ),
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