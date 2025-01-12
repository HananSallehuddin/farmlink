import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farmlink/controllers/CartController.dart';
import 'package:farmlink/controllers/UserController.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class LoginController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final userController = Get.find<UserController>();
  var uid = ''.obs;
  var role = ''.obs;

  var isLoggedIn = false.obs; 
  var errorMessage = ''.obs; 

   Future<void> clearUserData() async {
    uid.value = '';  
    role.value = '';  

    await FirebaseAuth.instance.signOut();

    Get.snackbar('Logged Out', 'You have been logged out.');
  }
  
  // Login user with email and password
  Future<void> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      // Sign in user with provided email and password
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Check if the email is verified
      if (userCredential.user?.emailVerified ?? false) {
        isLoggedIn.value = true; //login successful
      } else {
        errorMessage.value = 'Please verify email before logging in';
      }
    } on FirebaseAuthException catch (e) {
      errorMessage.value = e.message ?? 'Login failed'; 
    } catch (e) {
      errorMessage.value = 'An unknown error occurred';
    }
  }

  Future<String?> getUserRole() async {
  User? user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    print('User UID: ${user.uid}');
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (snapshot.exists && snapshot.data() != null) {
        String? role = snapshot['role'];
        print('User role retrieved: $role');
        return role;
      } else {
        print('User document does not exist in Firestore');
        return null;
      }
    } catch (e) {
      print('Error fetching user role: $e');
      return null;
    }
  } else {
    print('No logged-in user found');
    return null;
  }
}



}