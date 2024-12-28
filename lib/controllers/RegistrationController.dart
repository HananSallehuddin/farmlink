import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farmlink/models/UserModel.dart';

class RegistrationController{
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //register user with firebase
  Future<String?> registerUser({
    required String username,
    required String email,
    required String password,
    required String role,
  }) async {
    try{
      //create user in firebase authentication
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email, 
        password: password,
      );

      //send email verification
      await userCredential.user?.sendEmailVerification();

      //create a UserModel and save to firestore
      UserModel newUser = UserModel(
        uid: userCredential.user!.uid,
        username: username, 
        email: email, 
        role: role,
      );

      await _firestore.collection('users').doc(newUser.uid).set(newUser.toJson());
      return null; //registration successful
    } on FirebaseAuthException catch (e) {
      return e.message; //return error message for display
    } catch (e) {
      return 'An unknown error occured'; //catch any other errors
    }
  }
}