import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farmlink/bottomNaviBarCustomer.dart';
import 'package:farmlink/controllers/RatingController.dart';
import 'package:farmlink/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ratingListForSellerUI extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final RatingController ratingController = Get.find<RatingController>();

    // Fetch ratings for the produce (product) when the screen is initialized
    ratingController.fetchProduceRatingForSeller();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Styles.primaryColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        title: Text('Product Ratings'),
      ),
      body: Obx(() {
        var ratingList = ratingController.produceRatingList;

        if (ratingList.isEmpty) {
          return Center(
            child: const Text('No ratings yet for this produce'),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: ratingList.length,
          itemBuilder: (context, index) {
            var rating = ratingList[index];

            return FutureBuilder<DocumentSnapshot>(
              future: rating.produceRef!.get(), // Fetch produce document
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator(); // Show loading indicator for product name
                }
                
                if (snapshot.hasError) {
                  return Center(child: Text('Error fetching product name'));
                }

                // Extract product name from the produce document
                String productName = snapshot.data?.get('productName') ?? 'Unknown Product';

                return Card(
                  margin: EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Display the product name at the top of each rating
                        Text(
                          'Product: $productName', // Product name from snapshot
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.star, color: Colors.amber, size: 30),
                            SizedBox(width: 8),
                            Text(
                              rating.score.toString(),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                rating.review,
                                style: TextStyle(fontSize: 16),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            SizedBox(width: 8),
                            Text(
                              "${rating.dateRated.toLocal()}".split(' ')[0],
                              style: TextStyle(fontSize: 14, color: Colors.grey),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      }),
      bottomNavigationBar: bottomNavigationBarCustomer(currentRoute: '/ratingListSeller'),
    );
  }
}