import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:farmlink/styles.dart';

class LandingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        color: Colors.white,  // Green background
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
}