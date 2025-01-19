import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farmlink/models/UserModel.dart';
import 'package:get/get.dart';

class RegistrationController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  Future<void> registerUser({
    required String username,
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Create user in Firebase Authentication
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Send email verification
      await userCredential.user?.sendEmailVerification();

      // Create a UserModel and save to Firestore
      UserModel newUser = UserModel(
        uid: userCredential.user!.uid,
        username: username,
        email: email,
        role: role,
        addresses: [],
      );

      // Save user data to Firestore
      await _firestore
          .collection('users')
          .doc(newUser.uid)
          .set(newUser.toJson());

      // Sign out user until email is verified
      await _auth.signOut();

      Get.snackbar(
        'Registration Successful',
        'Please check your email to verify your account before logging in.',
        duration: Duration(seconds: 5),
      );

      // Navigate to login page
      Get.offAllNamed('/login');
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);
    } catch (e) {
      print('Registration error: $e');
      errorMessage.value = 'An unexpected error occurred during registration';
    } finally {
      isLoading.value = false;
    }
  }

  void _handleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        errorMessage.value = 'The password provided is too weak';
        break;
      case 'email-already-in-use':
        errorMessage.value = 'An account already exists for this email';
        break;
      case 'invalid-email':
        errorMessage.value = 'The email address is not valid';
        break;
      case 'operation-not-allowed':
        errorMessage.value = 'Email/password accounts are not enabled';
        break;
      default:
        errorMessage.value = e.message ?? 'Registration failed';
    }
  }

  bool validateRegistrationData({
    required String username,
    required String email,
    required String password,
    required String role,
  }) {
    if (username.isEmpty) {
      errorMessage.value = 'Username is required';
      return false;
    }

    if (email.isEmpty) {
      errorMessage.value = 'Email is required';
      return false;
    }

    if (!GetUtils.isEmail(email)) {
      errorMessage.value = 'Please enter a valid email address';
      return false;
    }

    if (password.isEmpty) {
      errorMessage.value = 'Password is required';
      return false;
    }

    if (role.isEmpty) {
      errorMessage.value = 'Please select a role';
      return false;
    }

    return true;
  }

  Future<bool> checkUsernameAvailability(String username) async {
    try {
      QuerySnapshot query = await _firestore
          .collection('users')
          .where('username', isEqualTo: username)
          .get();
      return query.docs.isEmpty;
    } catch (e) {
      print('Error checking username availability: $e');
      return false;
    }
  }

  void clearError() {
    errorMessage.value = '';
  }
}