import 'package:farmlink/bottomNaviBarCustomer.dart';
import 'package:farmlink/controllers/RatingController.dart';
import 'package:farmlink/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ratingListUI extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ratingController = Get.find<RatingController>();
    final String? pid = Get.parameters['pid'];

    // Fetch ratings for the produce (product) when the screen is initialized
    if (pid != null) {
      ratingController.fetchProduceRating(pid);
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Styles.primaryColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        title: Text('Ratings'),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Styles.primaryColor,
        onPressed: () async {
          bool? rateProduce = await _showRateDialog(context);
          if (!Get.isRegistered<RatingController>()) {
            return;
          }

          if (rateProduce == null || !rateProduce) {
            return;
          }

          Get.toNamed('rateProduce', parameters: {'pid': pid!});
        },
        elevation: 3,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Obx(() {
        var ratingList = ratingController.produceRatingList;

        if (ratingList.isEmpty) {
          return Center(
            child: const Text('No ratings yet'),
          );
        }

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
                    Text(
                      rating.score.toString(),
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.star, color: Colors.amber, size: 30),
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
              ),
            );
          },
        );
      }),
      bottomNavigationBar: bottomNavigationBarCustomer(currentRoute: '/ratingList'),
    );
  }

  Future<bool?> _showRateDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Rate Produce'),
          content: Text('Would you like to rate this produce?'),
          actions: <Widget>[
            TextButton(
              child: Text('Yes'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
            TextButton(
              child: Text('No'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
          ],
        );
      },
    );
  }
}