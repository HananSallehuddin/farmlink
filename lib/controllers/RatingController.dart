import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farmlink/controllers/UserController.dart';
import 'package:farmlink/models/Rating.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class RatingController extends GetxController{
  var produceRatingList = <Rating>[].obs;
  var sellerRatingList = <Rating>[].obs;
  

  Future<void> addProduceRating(String pid, Rating rating) async{
    try{
      DocumentReference produceRef = FirebaseFirestore.instance.collection('localProduce').doc(pid);
      rating.produceRef = produceRef;
      await FirebaseFirestore.instance.collection('ratings').add(rating.toJson());
      produceRatingList.add(rating);
    } catch(e) {
      print('Error adding rating: $e');
    }
  }

  Future<void> fetchProduceRating(String pid) async{
    try{
      DocumentReference produceRef = FirebaseFirestore.instance.collection('localProduce').doc(pid);
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance 
            .collection('ratings')
            .where('produceRef', isEqualTo: produceRef)
            .where('type', isEqualTo: 'produce')
            .get();
      
      //map query result to rating object and update local list
      produceRatingList.value = querySnapshot.docs.map((doc) {
        return Rating.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();
    } catch (e){
      print('Error fetching ratings for produce: $e');
    }
  }

  Future<void> fetchProduceRatingForSeller() async {
  try {
    User? currentUser = FirebaseAuth.instance.currentUser;
    
    // Check if the user is logged in
    if (currentUser == null) {
      Get.snackbar('Error', 'No user is currently logged in');
      return;
    }

    String uid = currentUser.uid; // Get the user's unique ID
    DocumentReference sellerRef = FirebaseFirestore.instance.collection('users').doc(uid);

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('ratings')
        .where('type', isEqualTo: 'produce')
        .where('sellerRef', isEqualTo: sellerRef)
        .get();

    if (querySnapshot.docs.isEmpty) {
      Get.snackbar('No Ratings', 'No ratings found for your produce.');
    } else {
      // Map query result to Rating objects and update local list
      produceRatingList.value = querySnapshot.docs.map((doc) {
        return Rating.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();
    }
  } catch (e) {
    print('Error fetching ratings for produce: $e');
    Get.snackbar('Error', 'An error occurred while fetching ratings.');
  }
}

Future<void> fetchSellerRatingForSeller() async {
  try {
    print("Fetching seller ratings for seller...");

    User? currentUser = FirebaseAuth.instance.currentUser;
    
    // Check if the user is logged in
    if (currentUser == null) {
      print("No user is currently logged in.");
      return;
    }

    String uid = currentUser.uid; // Get the user's unique ID
    print("Current user's UID: $uid");

    DocumentReference sellerRef = FirebaseFirestore.instance.collection('users').doc(uid);
    print("Seller reference: $sellerRef");

    // Firestore query to get ratings for this seller
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('ratings')
        .where('sellerRef', isEqualTo: sellerRef)
        .where('type', isEqualTo: 'seller')
        .get();

    print("Query executed. Found ${querySnapshot.docs.length} seller ratings.");
    
    if (querySnapshot.docs.isEmpty) {
      print("No seller ratings found for this seller.");
    } else {
      print("Ratings found. Parsing data...");
      sellerRatingList.value = querySnapshot.docs.map((doc) {
        return Rating.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();
      print("Parsed ${sellerRatingList.value.length} ratings.");
    }
  } catch (e) {
    print("Error fetching seller ratings for seller: $e");
  }
}

  Future<void> addSellerRating(String pid, Rating rating) async {
  try {
    DocumentReference produceRef = FirebaseFirestore.instance.collection('localProduce').doc(pid);
    
    // Assign the produce reference to the rating object
    rating.produceRef = produceRef;
    
    // Set the 'type' to 'seller'
    //rating.type = 'seller';
    
    // Add the rating to Firestore
    await FirebaseFirestore.instance.collection('ratings').add(rating.toJson());

    // Optionally add it to the local list (this depends on your setup)
    sellerRatingList.add(rating);
    
    print("Seller rating added successfully.");
  } catch (e) {
    print('Error adding seller rating: $e');
  }
}

  Future<void> fetchSellerRating(String pid) async{
    try{
      print("Fetching seller ratings for produce with ID: $pid");
      DocumentReference produceRef = FirebaseFirestore.instance.collection('localProduce').doc(pid);
      DocumentSnapshot produceDoc = await produceRef.get();
      DocumentReference sellerRef = produceDoc['userRef'] as DocumentReference;
      print("Seller reference: $sellerRef");

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
                .collection('ratings')
                .where('sellerRef', isEqualTo: sellerRef)
                .where('type', isEqualTo: 'seller')
                .get();
      print("Found ${querySnapshot.docs.length} seller ratings"); 
      sellerRatingList.value = querySnapshot.docs.map((doc) {
        return Rating.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();
    } catch(e) {
      print('Error adding rating: $e');
    }
  }

}