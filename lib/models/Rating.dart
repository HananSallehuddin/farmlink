import 'package:cloud_firestore/cloud_firestore.dart';

class Rating{
  String rid;
  int score;
  String review;
  DateTime dateRated;
  DocumentReference? customerRef;
  DocumentReference? sellerRef;
  DocumentReference? produceRef;
  String type;

  Rating({
    required this.rid,
    required this.score,
    required this.review,
    required this.dateRated,
    this.customerRef,
    this.sellerRef,
    this.produceRef,
    required this.type,
  });

  Map<String, dynamic> toJson(){
    return{
      'rid': rid,
      'score': score,
      'review': review,
      'dateRated': Timestamp.fromDate(dateRated),
      'customerRef': customerRef,
      'sellerRef': sellerRef,
      'produceRef': produceRef,
      'type': type,
    };
  }

  factory Rating.fromJson(Map<String, dynamic> json){
    return Rating(
      rid: json['rid'] as String, 
      score: json['score'] as int, 
      review: json['review'] as String,
      dateRated: (json['dateRated'] as Timestamp).toDate(),
      customerRef: json['customerRef'] as DocumentReference?,
      sellerRef: json['sellerRef'] as DocumentReference?,
      produceRef: json['produceRef'] as DocumentReference?,
      type: json['type'] as String,
      );
  }
}