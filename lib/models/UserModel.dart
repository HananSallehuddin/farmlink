import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String username;
  final String email;
  final String role;
  List<Address>? addresses;

  //constructor
  UserModel({
    required this.uid,
    required this.username,
    required this.email,
    required this.role,
    this.addresses,
  });

  //Convert UserModel to JSON for Firestore
  Map<String, dynamic> toJson() {
    return{
      'uid': uid,
      'username': username,
      'email': email,
      'role': role,
      'addresses': addresses?.map((address) => address.toJson()).toList(),
    };
  }

  //Create a UserModel from FireStore document
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      addresses: (json['addresses'] as List<dynamic>?)?.map((e)=> Address.fromJson(e)).toList(),
    );
  }
}

// class Address {
//   final String address;
//   final String zipCode;
//   final String city;
//   final String state;
//   final DocumentReference? reference;  // Nullable reference

//   Address({
//     required this.address,
//     required this.zipCode,
//     required this.city,
//     required this.state,
//     this.reference,  // Nullable reference
//   });

//   // Convert to Firestore-compatible map
//   Map<String, dynamic> toJson() {
//     return {
//       'address': address,
//       'zipCode': zipCode,
//       'city': city,
//       'state': state,
//       'reference': reference?.path,  // Reference is nullable, so handle it safely
//     };
//   }

//   // Create class from Firestore document
//   factory Address.fromJson(Map<String, dynamic> json) {
//     return Address(
//       address: json['address'] as String,
//       zipCode: json['zipCode'] as String,
//       city: json['city'] as String,
//       state: json['state'] as String,
//       reference: json['reference'] != null
//           ? FirebaseFirestore.instance.doc(json['reference'])  // Safely parse reference
//           : null,
//     );
//   }
// }

class Address {
  final String address;
  final String zipCode;
  final String city;
  final String state;
  final DocumentReference? reference; // Make reference nullable

  Address({
    required this.address,
    required this.zipCode,
    required this.city,
    required this.state,
    this.reference,  // nullable reference
  });

  factory Address.fromJson(Map<String, dynamic> json) {
  // Ensure the reference is properly fetched from Firestore
  final reference = json['reference'] != null
      ? FirebaseFirestore.instance.doc(json['reference'])  // Make sure this is the correct path to the document
      : null;

  return Address(
    address: json['address'] as String,
    zipCode: json['zipCode'] as String,
    city: json['city'] as String,
    state: json['state'] as String,
    reference: reference,  // Ensure that the reference is set correctly
  );
}

  Map<String, dynamic> toJson() {
    return {
      'address': address,
      'zipCode': zipCode,
      'city': city,
      'state': state,
      'reference': reference?.path,  // Store reference path if it's not null
    };
  }

  @override
  String toString() {
    return 'Address: $address, $city, $state, $zipCode';
  }
}