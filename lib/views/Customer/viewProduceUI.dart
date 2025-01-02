import 'package:farmlink/bottomNaviBarCustomer.dart';
import 'package:farmlink/controllers/ProductController.dart';
import 'package:farmlink/models/LocalProduce.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:carousel_slider/carousel_slider.dart';

class viewProduceUI extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    final productController = Get.find<ProductController>();
    final String? pid = Get.parameters['pid'];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Stack(
              children: [
                Icon(Icons.shopping_cart_outlined),
                Positioned(
                  top: 0,
                  right: 0,
                  child: CircleAvatar(
                    radius: 8,
                    backgroundColor: Colors.amber,
                    child: Text(
                      '20', // Replace with dynamic cart count
                      style: TextStyle(fontSize: 12, color: Colors.black),
                    ),
                  ),
                ),
              ],
            ),
            onPressed: () {
              // Navigate to cart
            },
          ),
        ],
      ),
      body: FutureBuilder<LocalProduce>(
        future: productController.viewProduceDetails(pid!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          } else if (!snapshot.hasData) {
            return Center(child: Text('Produce not found'));
          }

          final produce = snapshot.data!;
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (produce.imageUrls.isNotEmpty)
                // Produce Image
                  Container(
                    color: Colors.pink[50],
                    child: CarouselSlider(
                      items: produce.imageUrls.map((imageUrl) {
                        return Builder(
                          builder: (BuildContext context) => Image.network(
                      imageUrl,
                      height: 250,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                    );
                      }).toList(),
                      options: CarouselOptions( 
                        height: 250,
                        enlargeCenterPage: true,
                        enableInfiniteScroll: true,
                        //autoplay: true,
                        viewportFraction: 1.0,
                      ),
                    ), 
                  ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Price and Rating Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'RM${produce.price.toStringAsFixed(2)}',
                            style: TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          Row(
                            children: [
                              Icon(Icons.star, color: Colors.amber, size: 20),
                              SizedBox(width: 4),
                              Text(
                                '4.89 (1000+)',
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      // Name
                      Text(
                        produce.productName,
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      // Description
                      Text(
                        produce.description,
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 16),
                      // Seller Info
                      Row(
                        // children: [
                        //   CircleAvatar(
                        //     radius: 24,
                        //     backgroundImage:
                        //         NetworkImage(produce.sellerProfilePicUrl),
                        //   ),
                        //   SizedBox(width: 8),
                        //   Text(
                        //     produce.sellerName,
                        //     style: TextStyle(fontSize: 18),
                        //   ),
                        //   Spacer(),
                        //   Icon(Icons.chat_bubble_outline),
                        // ],
                      ),
                      SizedBox(height: 16),
                      // Add to Cart Button
                      Center(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // Add to cart logic
                          },
                          icon: Icon(Icons.add_shopping_cart),
                          label: Text('Add To Cart'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[200],
                            padding: EdgeInsets.symmetric(
                                horizontal: 32, vertical: 12),
                            textStyle: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: bottomNavigationBarCustomer(currentRoute: '/viewProduce',)
    );
  }
}