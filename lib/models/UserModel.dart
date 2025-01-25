import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String username;
  final String email;
  final String role;
  List<Address>? addresses;

  // Constructor
  UserModel({
    required this.uid,
    required this.username,
    required this.email,
    required this.role,
    this.addresses,
  });

  // Convert UserModel to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'username': username,
      'email': email,
      'role': role,
      'addresses': addresses?.map((address) => address.toJson()).toList(),
    };
  }

  // Create a UserModel from Firestore document
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      addresses: (json['addresses'] as List<dynamic>?)?.map((e) => Address.fromJson(e)).toList(),
    );
  }
}

class Address {
  final String address;
  final String zipCode;
  final String city;
  final String state;
  final DocumentReference? reference; 

  // Constructor
  Address({
    required this.address,
    required this.zipCode,
    required this.city,
    required this.state,
    this.reference,
  });

  // Convert Address to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'address': address,
      'zipCode': zipCode,
      'city': city,
      'state': state,
      'reference': reference?.path,
    };
  }

  // Create an Address from Firestore document
  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      address: json['address'] as String,
      zipCode: json['zipCode'] as String,
      city: json['city'] as String,
      state: json['state'] as String,
    );
  }
}