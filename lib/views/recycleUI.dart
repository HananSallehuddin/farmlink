import 'package:farmlink/bottomNaviBarSeller.dart';
import 'package:farmlink/controllers/ProductController.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class recycleUI extends StatelessWidget {
  const recycleUI({super.key});

  @override
  Widget build(BuildContext context) {
    final productController = Get.find<ProductController>();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Get.toNamed('homepageSeller');
          },
        ),
        title: Text("Recycled Produce"),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 4,
      ),
      body: Column(
        children: [
          // Display products in a 2x2 grid
          Obx(() {
            if (productController.recycledProduceList.isEmpty) {
              return Center(child: Text('No recycled products.'));
            }
            return GridView.builder(
              shrinkWrap: true, // Ensures that GridView takes only the space it needs
              physics: NeverScrollableScrollPhysics(), // Disable scrolling since it's in a Column
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // 2 items per row
                crossAxisSpacing: 10, // Space between columns
                mainAxisSpacing: 10, // Space between rows
                childAspectRatio: 0.7, // Aspect ratio for grid items
              ),
              itemCount: productController.recycledProduceList.length,
              itemBuilder: (context, index) {
                final produce = productController.recycledProduceList[index];
                return GestureDetector(
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 5,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Display product image
                        Expanded(
                          child: produce.imageUrls.isNotEmpty
                              ? Image.network(
                                  produce.imageUrls[0],
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                )
                              : Container(
                                  color: Colors.grey, // Grey background when no image is available
                                  width: double.infinity,
                                  child: Center(
                                    child: Icon(
                                      Icons.image, // Optional: icon to indicate no image
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Display product name
                              Text(
                                produce.productName,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(height: 5),
                              // Display price
                              Text(
                                '\$${produce.price.toStringAsFixed(2)}',
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
        ],
      ),
    );
  }
}