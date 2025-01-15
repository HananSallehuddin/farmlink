import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farmlink/models/Rating.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class RatingController extends GetxController{
  var ratingList = <Rating>[].obs;
  
  // void onInit(){
  //   super.onInit();
  // }

  Future<void> addProduceRating(String pid, Rating rating) async{
    try{
      DocumentReference produceRef = FirebaseFirestore.instance.collection('localProduce').doc(pid);
      rating.produceRef = produceRef;
      await FirebaseFirestore.instance.collection('ratings').add(rating.toJson());
      ratingList.add(rating);
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
            .get();
      
      //map query result to rating object and update local list
      ratingList.value = querySnapshot.docs.map((doc) {
        return Rating.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();
    } catch (e){
      print('Error fetching ratings for produce: $e');
    }

  }
}