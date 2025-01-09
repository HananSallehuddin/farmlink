import 'package:farmlink/bottomNaviBarCustomer.dart';
import 'package:farmlink/controllers/CartController.dart';
import 'package:farmlink/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:farmlink/controllers/ProductController.dart'; // Import the controller

class HomepageCustomer extends StatelessWidget {
  const HomepageCustomer({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize the ProductController
    final productController = Get.find<ProductController>();
    final cartController = Get.find<CartController>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      cartController.createCart();
    });

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
                onChanged: (value) {
                  productController.filterProduce(value);
                },
              ),
            ),
            SizedBox(width: 10),
          ],
        ),
        actions: [
          Obx(() {
            return IconButton(
              icon: Stack(
                children: [
                  Icon(Icons.shopping_cart_outlined),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: CircleAvatar(
                      radius: 8,
                      backgroundColor: Colors.amber,
                      child: Text(
                        '${cartController.cart.value.quantity.isEmpty ? 0 
                        : cartController.cart.value.quantity.values.fold<int>(0, (prev, qty) => prev + qty)}',
                        style: TextStyle(fontSize: 12, color: Colors.black),
                      ),
                    ),
                  ),
                ],
              ),
              onPressed: () {
                Get.toNamed('viewCart');
              },
            );
          }),
        ],
      ),
      body: Column(
        children: [
          //display product in 2x2 grid
          Expanded(
            child: Obx(() {
              if (productController.filteredProduceList.isEmpty) { 
                return Center(child: Text('No produce'));
              }
              return GridView.builder(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, //2 items per row
                  crossAxisSpacing: 10, //space between columns
                  mainAxisSpacing: 10, //space between rows
                  childAspectRatio: 0.7, //adjust aspect ratio to control item size
                ),
                itemCount: productController.filteredProduceList.length,
                itemBuilder: (context, index) {
                  final product = productController.filteredProduceList[index];
                  return GestureDetector(
                    onTap: () {
                      if (product.pid == null) {
                        print("Product ID is null for ${product.productName}");
                        Get.snackbar('Error', 'Product ID is missing');
                      } else {
                        print('Navigating to viewProduce with pid: ${product.pid}');
                        Get.toNamed('/viewProduce', parameters: {'pid': product.pid.toString()});
                      }
                    },
                    child: Card(
                      shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                      elevation: 5,

                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                        //display product image
                          Expanded(
                            child: product.imageUrls.isNotEmpty
                                ? Image.network(
                                  product.imageUrls[0],
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                )
                                : Container(
                                    color: Colors.grey,  // Grey background when no image is available
                                    width: double.infinity,
                                    child: Center(
                                      child: Icon(
                                        Icons.image,  // Optional: icon to indicate no image
                                        color: Colors.white,
                                      ),
                                    ),
                                  ), //if no image, show palceholder
                                ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                //display product name
                                Text(
                                  product.productName,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                SizedBox(height: 5),
                              //Display price
                                Text(
                                  '\RM${product.price.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 14,
                                  ),
                                ),
                                SizedBox(height: 5),
                            ],
                          ),
                          ),
                      ],
                    ),
              ),
            );
                },
                );
            }),
          ),
        ],
      ),
      //reusable bottom navi bar
      bottomNavigationBar: bottomNavigationBarCustomer(currentRoute: '/homepageCustomer')
    );
  }
}