import 'package:cloud_firestore/cloud_firestore.dart';

class LocalProduce {
  String pid;
  String productName;
  double price;
  String description;
  List<String> imageUrls;
  int stock;
  DateTime expiryDate;
  DocumentReference? userRef;

  //constructor
  LocalProduce({
    required this.pid,
    required this.productName,
    required this.price,
    required this.description,
    required this.imageUrls,
    required this.stock,
    required this.expiryDate,
    this.userRef, //optional parameter to link product to user
  });
  //convert to firestore-comaptible map
  Map<String, dynamic> toJson() {
    return{
      'pid' : pid,
      'productName' : productName,
      'price' : price,
      'description' : description,
      'imageUrls' : imageUrls,
      'stock' : stock,
      'expiryDate': Timestamp.fromDate(expiryDate), // Convert DateTime to Timestamp      
      'userRef': userRef,
    };
  }
  //create class from firestore document
  factory LocalProduce.fromJson(Map<String, dynamic> json) {
    return LocalProduce(
      pid: json['pid'] as String, 
      productName: json['productName'] as String, 
      price: (json['price'] as num).toDouble(), // Handle Firestore number type
      description: json['description'] as String, 
      imageUrls: List<String>.from(json['imageUrls'] as List), 
      stock: json['stock'] as int, 
      expiryDate: (json['expiryDate'] as Timestamp).toDate(),
      userRef: json['userRef'] as DocumentReference?,
      );
  } 
}