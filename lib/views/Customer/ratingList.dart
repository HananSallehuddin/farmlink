import 'package:farmlink/controllers/RatingController.dart';
import 'package:farmlink/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ratingListUI extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    final ratingController = Get.put(RatingController());
    final String? pid = Get.parameters['pid'];
    
    // Fetch ratings for the produce (product) when the screen is initialized
    ratingController.fetchProduceRating(pid!);

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Styles.primaryColor,
        onPressed: () => Get.toNamed('rateProduce', parameters: {'pid': pid!}),
        elevation: 3,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      appBar: AppBar(
        backgroundColor: Styles.primaryColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        title: Text('Produce Rating'),
      ),
      body: Obx(() {
        var ratingList = ratingController.ratingList;
        
        // If there are no ratings, display a message
        if (ratingList.isEmpty) {
          return Center(
            child: const Text('No ratings yet'),
          );
        }

        // Display the ratings in a ListView
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: ratingList.length,
          itemBuilder: (context, index) {
            var rating = ratingList[index];

            return Card(
              margin: EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    // Star icon and score
                    Icon(Icons.star, color: Colors.amber, size: 30),
                    SizedBox(width: 8),
                    Text(
                      rating.score.toString(),
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(width: 8),
                    // Review text
                    Expanded(
                      child: Text(
                        rating.review,
                        style: TextStyle(fontSize: 16),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: 8),
                    // Date of rating
                    Text(
                      "${rating.dateRated.toLocal()}".split(' ')[0],
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }
}