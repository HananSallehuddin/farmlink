import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farmlink/controllers/UserController.dart';
import 'package:farmlink/services/NotificationService.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class LoginController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final userController = Get.find<UserController>();

  var isLoggedIn = false.obs;
  var errorMessage = ''.obs;
  var isLoading = false.obs;
  var currentUser = Rxn<User>();
  
  @override
  void onInit() {
    super.onInit();
    _auth.authStateChanges().listen((User? user) {
      currentUser.value = user;
      isLoggedIn.value = user != null;
    });
  }

  Future<void> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Clear previous state
      await _auth.signOut();
      userController.clearUserData();
      Get.delete<String>(tag: 'currentRole', force: true);

      // Perform login
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user?.emailVerified ?? false) {
        // Fetch user data
        final DocumentSnapshot userDoc = await _firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .get();

        if (userDoc.exists) {
          final userData = userDoc.data() as Map<String, dynamic>;
          final role = userData['role'] as String?;

          if (role != null) {
            // Pre-load role to prevent navigation bar flicker
            await Get.putAsync(() async => role, tag: 'currentRole', permanent: true);

            final notificationService = Get.find<NotificationService>();
            await notificationService.updateUnreadChatCount();
            await notificationService.updateUnreadOrderCount();
            
            // Update state
            isLoggedIn.value = true;
            
            // Add small delay to ensure states are updated
            await Future.delayed(Duration(milliseconds: 100));

            // Navigate based on role
            if (role == 'Seller') {
              await Get.offAllNamed('/homepageSeller');
            } else if (role == 'Customer') {
              await Get.offAllNamed('/homepageCustomer');
            } else {
              errorMessage.value = 'Invalid user role';
              await _handleLogout();
            }
          } else {
            errorMessage.value = 'Invalid user role';
            await _handleLogout();
          }
        } else {
          errorMessage.value = 'User data not found';
          await _handleLogout();
        }
      } else {
        // Send verification email if not verified
        await userCredential.user?.sendEmailVerification();
        errorMessage.value = 'Please verify your email before logging in. A verification email has been sent.';
        await _handleLogout();
      }
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);
    } catch (e) {
      print('Login error: $e');
      errorMessage.value = 'An unexpected error occurred';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _handleLogout() async {
    try {
      await _auth.signOut();
      isLoggedIn.value = false;
      isLoading.value = false;  // Reset loading state
      currentUser.value = null;
      Get.delete<String>(tag: 'currentRole', force: true);
      userController.clearUserData();
    } catch (e) {
      print('Error during logout: $e');
    } finally {
      isLoading.value = false;  // Ensure loading state is reset
    }
  }

  void _handleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        errorMessage.value = 'No user found with this email';
        break;
      case 'wrong-password':
        errorMessage.value = 'Incorrect password';
        break;
      case 'user-disabled':
        errorMessage.value = 'This account has been disabled';
        break;
      case 'invalid-email':
        errorMessage.value = 'Invalid email address';
        break;
      case 'too-many-requests':
        errorMessage.value = 'Too many login attempts. Please try again later';
        break;
      default:
        errorMessage.value = 'Login failed: ${e.message}';
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      await _auth.sendPasswordResetEmail(email: email);
      Get.snackbar('Success', 'Password reset email sent. Please check your inbox.');
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'invalid-email':
          errorMessage.value = 'Invalid email address';
          break;
        case 'user-not-found':
          errorMessage.value = 'No user found with this email';
          break;
        default:
          errorMessage.value = 'Failed to send reset email: ${e.message}';
      }
    } catch (e) {
      errorMessage.value = 'An unexpected error occurred';
      print('Reset password error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<String?> getUserRole() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        DocumentSnapshot snapshot = await _firestore
            .collection('users')
            .doc(user.uid)
            .get();
        
        if (snapshot.exists && snapshot.data() != null) {
          Map<String, dynamic> userData = snapshot.data() as Map<String, dynamic>;
          return userData['role'] as String?;
        }
      }
      return null;
    } catch (e) {
      print('Error fetching user role: $e');
      return null;
    }
  }

  Future<void> signOut() async {
    try {
      await _handleLogout();
      isLoading.value = false;  // Reset loading state
      await Get.offAllNamed('/login');
    } catch (e) {
      print('Error signing out: $e');
      errorMessage.value = 'Failed to sign out';
    } finally {
      isLoading.value = false;  // Ensure loading state is reset even if error occurs
    }
  }

  Future<void> updateEmail(String newEmail, String password) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      User? user = _auth.currentUser;
      if (user == null) throw Exception('No user logged in');

      // Reauthenticate user before changing email
      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password
      );
      await user.reauthenticateWithCredential(credential);

      // Update email
      await user.verifyBeforeUpdateEmail(newEmail);
      Get.snackbar('Success', 'Verification email sent to new address. Please verify to complete the change.');
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);
    } catch (e) {
      errorMessage.value = 'Failed to update email';
      print('Update email error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updatePassword(String currentPassword, String newPassword) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      User? user = _auth.currentUser;
      if (user == null) throw Exception('No user logged in');

      // Reauthenticate user before changing password
      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword
      );
      await user.reauthenticateWithCredential(credential);

      // Update password
      await user.updatePassword(newPassword);
      Get.snackbar('Success', 'Password updated successfully');
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);
    } catch (e) {
      errorMessage.value = 'Failed to update password';
      print('Update password error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteAccount(String password) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      User? user = _auth.currentUser;
      if (user == null) throw Exception('No user logged in');

      // Reauthenticate user before deletion
      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password
      );
      await user.reauthenticateWithCredential(credential);

      // Delete user data from Firestore
      await _firestore.collection('users').doc(user.uid).delete();

      // Delete user account
      await user.delete();
      Get.offAllNamed('/login');
      Get.snackbar('Success', 'Account deleted successfully');
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);
    } catch (e) {
      errorMessage.value = 'Failed to delete account';
      print('Delete account error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  bool validatePassword(String password) {
    // Simple check for non-empty password for debugging purposes
    return password.isNotEmpty;
  }

  bool validateEmail(String email) {
    // Basic email validation
    RegExp emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
    );
    return emailRegex.hasMatch(email);
  }
}