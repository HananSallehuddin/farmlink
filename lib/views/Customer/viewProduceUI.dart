import 'package:farmlink/bottomNaviBarCustomer.dart';
import 'package:farmlink/controllers/CartController.dart';
import 'package:farmlink/controllers/ProductController.dart';
import 'package:farmlink/models/LocalProduce.dart';
import 'package:farmlink/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:carousel_slider/carousel_slider.dart';

class viewProduceUI extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    final productController = Get.find<ProductController>();
    final cartController = Get.find<CartController>();
    final String? pid = Get.parameters['pid'];
    if (pid == null) {
      return Center(child: Text('Invalid or missing pid'));
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
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
      body: FutureBuilder<LocalProduce>(
        future: productController.viewProduceDetails(pid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          } else if (!snapshot.hasData) {
            return Center(child: Text('Produce not found'));
          }

          final produce = snapshot.data!;
          productController.stock.value = produce.stock;
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
                            style: const TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          const Row(
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
                      //stock status
                      Obx(() {
                        return Text(  
                        productController.stock.value > 0
                          ? 'In Stock: ${productController.stock.value}'
                          : 'Out of stock',
                        style: TextStyle( 
                          color: produce.stock > 0 ? Colors.green : Colors.red,
                          fontSize: 16,
                        ),
                      );
                      }),
                      
                      SizedBox(height: 16),
                      // Add to Cart Button
                      Center(
                        child: ElevatedButton.icon(
                          onPressed: produce.stock > 0 
                              ? () {
                                cartController.addProduceToCart(produce);
                               }
                            : null,
                          // icon: Icon(Icons.add_shopping_cart),
                          label: Text(
                            produce.stock > 0 ? 'Add to cart' : 'Out of stock',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:produce.stock > 0
                                ? Styles.primaryColor
                                : Colors.grey,
                            padding: EdgeInsets.symmetric(
                                horizontal: 32, vertical: 12),
                            textStyle: TextStyle(fontSize: 16),
                          ), //disable button if out of stock                        
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
      bottomNavigationBar: bottomNavigationBarCustomer(currentRoute: '/viewProduce',),
    );
  }
}