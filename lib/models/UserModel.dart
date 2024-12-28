class UserModel {
  final String uid;
  final String username;
  final String email;
  final String role;
  //constructor
  UserModel({
    required this.uid,
    required this.username,
    required this.email,
    required this.role,
  });

  //Convert UserModel to JSON for Firestore
  Map<String, dynamic> toJson() {
    return{
      'uid': uid,
      'username': username,
      'email': email,
      'role': role,
    };
  }

  //Create a UserModel from FireStore document
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
    );
  }
}