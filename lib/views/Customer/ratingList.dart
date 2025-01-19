import 'package:farmlink/bottomNaviBarCustomer.dart';
import 'package:farmlink/controllers/RatingController.dart';
import 'package:farmlink/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ratingListUI extends StatefulWidget {
  @override
  _ratingListUIState createState() => _ratingListUIState();
}

class _ratingListUIState extends State<ratingListUI> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
void initState() {
  super.initState();
  _tabController = TabController(length: 2, vsync: this);

  // Listen for tab changes
  _tabController.addListener(() {
    if (_tabController.index == 1) { // If it's the 'Seller Ratings' tab
      final String? pid = Get.parameters['pid'];
      if (pid != null) {
        final ratingController = Get.put(RatingController());
        ratingController.fetchSellerRating(pid);
      }
    }
  });
}

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ratingController = Get.put(RatingController());
    final String? pid = Get.parameters['pid'];

    // Fetch ratings for the produce (product) when the screen is initialized
    ratingController.fetchProduceRating(pid!);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Styles.primaryColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        title: Text('Ratings'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Produce Ratings'),
            Tab(text: 'Seller Ratings'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Styles.primaryColor,
        onPressed: () async {
          bool? rateProduce = await _showRateDialog(context);
          if (!Get.isRegistered<RatingController>()) {
            return;
          }

          if (rateProduce == null) {
            return;
          }

          if (rateProduce) {
            Get.toNamed('rateProduce', parameters: {'pid': pid!});
          } else {
            Get.toNamed('rateSeller', parameters: {'pid': pid!});
          }
        },
        elevation: 3,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Produce ratings tab
          Obx(() {
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

                return Card(
                  margin: EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 30),
                        SizedBox(width: 8),
                        Text(
                          rating.score.toString(),
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                  ),
                );
              },
            );
          }),
          // Seller ratings tab
          Obx(() {
            var ratingList = ratingController.sellerRatingList;

            if (ratingList.isEmpty) {
              return Center(
                child: const Text('No ratings yet for this seller'),
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
                        Icon(Icons.star, color: Colors.amber, size: 30),
                        SizedBox(width: 8),
                        Text(
                          rating.score.toString(),
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                  ),
                );
              },
            );
          }),
        ],
      ),
      bottomNavigationBar: bottomNavigationBarCustomer(currentRoute: '/ratingList'),
    );
  }

  Future<bool?> _showRateDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Rate Seller or Produce'),
          content: Text('Would you like to rate produce or seller?'),
          actions: <Widget>[
            TextButton(
              child: Text('Rate Produce'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
            TextButton(
              child: Text('Rate Seller'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}