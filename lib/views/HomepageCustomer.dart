import 'package:farmlink/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:farmlink/controllers/ProductController.dart'; // Import the controller

class HomepageCustomer extends StatelessWidget {
  const HomepageCustomer({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize the ProductController
    final productController = Get.put(ProductController());

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            // Search bar
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search...',
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            SizedBox(width: 10),
            // Add button
            GestureDetector(
              onTap: () {
                // Show dialog to upload product
                showDialog(
                  context: context,
                  builder: (context) {
                    String newProduct = '';
                    return AlertDialog(
                      title: Text('Add Product'),
                      content: TextField(
                        onChanged: (value) => newProduct = value,
                        decoration: InputDecoration(hintText: 'Enter product name'),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            if (newProduct.isNotEmpty) {
                              productController.addProductToListing();
                              Navigator.of(context).pop();
                            }
                          },
                          child: Text('Add'),
                        ),
                      ],
                    );
                  },
                );
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Styles.secondaryColor,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Icon(Icons.shopping_cart, color: Styles.subtitleColor),
              ),
            ),
          ],
        ),
      ),
      // body: Column(
      //   children: [
      //     // Product list
      //     Expanded(
      //       child: Obx(() {
      //         if (productController.products.isEmpty) {
      //           return Center(child: Text('No products uploaded yet.'));
      //         }
      //         return ListView.builder(
      //           itemCount: productController.products.length,
      //           itemBuilder: (context, index) {
      //             return ListTile(
      //               title: Text(productController.products[index]),
      //             );
      //           },
      //         );
      //       }),
      //     ),
      //   ],
      // ),
      // // Bottom App Bar
      bottomNavigationBar: BottomAppBar(
        color: Styles.secondaryColor,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // Chat Button
            IconButton(
              icon: Icon(Icons.chat),
              color: Styles.subtitleColor,
              onPressed: () {
                Get.toNamed('/chat');
              },
            ),
            // Home Button
            IconButton(
              icon: Icon(Icons.home),
              color: Styles.subtitleColor,
              onPressed: () {
                Get.toNamed('/homepageSeller');
              },
            ),
            // Profile Button
            IconButton(
              icon: Icon(Icons.person),
              color: Styles.subtitleColor,
              onPressed: () {
                Get.toNamed('/profile');
              },
            ),
          ],
        ),
      ),
    );
  }
}