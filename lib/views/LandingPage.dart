import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:farmlink/styles.dart';

class LandingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              Styles.primaryColor.withOpacity(0.1),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Expanded(
                flex: 3,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      "assets/farmlink logo wo quotes.png",
                      height: 350,
                      fit: BoxFit.contain,
                    ),
                    //const SizedBox(height: 8),
                    Text(
                      'Connect with Local Farmers',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Styles.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Fresh Produce, Direct to You',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),

              // Buttons
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Get Started Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => Get.toNamed('/register'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Styles.primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 2,
                          ),
                          child: const Text(
                            'Get Started',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Login Button
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () => Get.toNamed('/login'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Styles.primaryColor,
                            side: BorderSide(color: Styles.primaryColor),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text(
                            'Login',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Footer
              // Padding(
              //   padding: const EdgeInsets.only(bottom: 24.0),
              //   child: Text(
              //     'Supporting Local Agriculture',
              //     style: TextStyle(
              //       color: Colors.grey[600],
              //       fontSize: 14,
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}