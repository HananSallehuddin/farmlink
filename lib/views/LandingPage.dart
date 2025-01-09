import 'package:farmlink/controllers/LoginController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:farmlink/styles.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LandingPage extends StatelessWidget {
  
  @override
  Widget build(BuildContext context) {
    // Call the initialization logic after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeUserState();
    });

    return Scaffold(
      body: Container(
        width: double.infinity,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                "assets/logo farmlink.png", // Replace with your logo path
                height: 400, // Adjust size if needed
              ),
              const SizedBox(height: 20), // Add spacing between logo and button
              ElevatedButton(
                onPressed: () {
                  Get.toNamed('/register'); 
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Styles.primaryColor, // Button background color
                  foregroundColor: Colors.white, // Text color
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15), // Button padding
                ),
                child: Text(
                  "Get Started", 
                  //style: Styles.buttonText,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  // This method handles the logic for user state initialization
  void _initializeUserState() {
    if (FirebaseAuth.instance.currentUser == null) {
      // No user is logged in, reset state
      Get.find<LoginController>().clearUserData();
    } else {
      // User is logged in, fetch their role or other data
      Get.find<LoginController>().getUserRole();
    }
  }
}