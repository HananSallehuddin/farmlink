import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class LoginController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  var isLoggedIn = false.obs; //reactive state for login status
  var errorMessage = ''.obs; //reactive status for error message

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
      errorMessage.value = e.message ?? 'Login failed'; // Return error message if login fails
    } catch (e) {
      errorMessage.value = 'An unknown error occurred';// Handle other errors
    }
  }

  // Future<String?> getUserRole() async {
  //   //get current user
  //   User? user = FirebaseAuth.instance.currentUser;
  //   if (user != null) {
  //     //fetch user data from firestore
  //     DocumentSnapshot snapshot = await FirebaseFirestore.instance
  //               .collection('users')
  //               .doc(user.uid)
  //               .get();
  //     //check if doc exists
  //     if (snapshot.exists) {
  //       return snapshot['role'];
  //     }
  //   }
  //   return null;
  // }

  Future<String?> getUserRole() async {
    //use to retrieve whole object
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