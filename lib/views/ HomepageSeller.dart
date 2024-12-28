import 'package:farmlink/bottomNaviBarSeller.dart';
import 'package:farmlink/routes.dart';
import 'package:farmlink/styles.dart';
import 'package:farmlink/views/productFormUI.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:farmlink/controllers/ProductController.dart'; // Import the controller

class HomepageSeller extends StatelessWidget {
  const HomepageSeller({super.key});

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
              ),
            ),
            SizedBox(width: 10),
            // Add button
            GestureDetector(
              onTap: () {
                Get.toNamed('/productForm');
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Styles.secondaryColor,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Icon(Icons.add, color: Styles.subtitleColor),
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
              if (productController.produceList.isEmpty) { 
                return Center(child: Text('No products uploaded yet.'));
              }
              return GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, //2 items per row
                  crossAxisSpacing: 10, //space between columns
                  mainAxisSpacing: 10, //space between rows
                  childAspectRatio: 0.7, //adjust aspect ratio to control item size
                ),
                itemCount: productController.produceList.length,
                itemBuilder: (context, index) {
                  final product = productController.produceList[index];
                  return GestureDetector(
                    onLongPress: (){
                      _showDeleteConfirmation(context, productController, product);
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
                                : Placeholder(fallbackHeight: 100), //if no image, show palceholder
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
      bottomNavigationBar: bottomNavigationBarSeller(currentRoute: '/homepageSeller')
    );
  }

 // Show a confirmation dialog when the user long presses on a product
  void _showDeleteConfirmation(BuildContext context, ProductController productController, var product) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Are you sure you want to delete this product?'),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      _deleteProduct(context, productController, product.pid); // Delete product
                    },
                    child: Text('Delete'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Get.back(); // Close the bottom sheet
                    },
                    child: Text('Cancel'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // Call the delete method from your ProductController to delete the product
  Future<void> _deleteProduct(BuildContext context, ProductController productController, String pid) async {
    try {
      await productController.deleteProductFromListing(pid); // Pass the product ID to the delete method
      Navigator.pop(context); // Close the bottom sheet
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete product');
    }
  }
}

