import 'package:farmlink/bottomNaviBarCustomer.dart';
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
            // Add button
            GestureDetector(
              // onTap: () {
              //   // Show dialog to upload product
              //   showDialog(
              //     context: context,
              //     builder: (context) {
              //       String newProduct = '';
              //       return AlertDialog(
              //         title: Text('Add Product'),
              //         content: TextField(
              //           onChanged: (value) => newProduct = value,
              //           decoration: InputDecoration(hintText: 'Enter product name'),
              //         ),
              //         actions: [
              //           TextButton(
              //             onPressed: () {
              //               if (newProduct.isNotEmpty) {
              //                 productController.addProductToListing();
              //                 Navigator.of(context).pop();
              //               }
              //             },
              //             child: Text('Add'),
              //           ),
              //         ],
              //       );
              //     },
              //   );
              // },
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
      body: Column(
        children: [
          //display product in 2x2 grid
          Expanded(
            child: Obx(() {
              if (productController.filteredProduceList.isEmpty) { 
                return Center(child: Text('No produce'));
              }
              return GridView.builder(
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
                      borderRadius: BorderRadius.circular(8),
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
                                  '\$${product.price.toStringAsFixed(2)}',
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