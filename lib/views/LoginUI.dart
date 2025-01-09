import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:farmlink/controllers/LoginController.dart';
import 'package:get/get.dart';
import 'package:farmlink/styles.dart';

class LoginUI extends StatelessWidget {
  const LoginUI({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize LoginController using GetX
    final loginController = Get.find<LoginController>();
    final _formKey = GlobalKey<FormState>(); // Form key for validation
    String? _email, _password; // Store email and password

    // Reactive boolean for toggling password visibility
    final RxBool showPassword = false.obs;

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Logo at the top
              Padding(
                padding: const EdgeInsets.only(top: 60.0),
                child: Center(
                  child: Image.asset(
                    'assets/farmlink logo wo quotes.png', // Replace with your logo path
                    width: 150,
                    height: 150,
                  ),
                ),
              ),

              // Greeting text
              const SizedBox(height: 24),
              const Text(
                'Log In',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Hello again, you\'ve been missed!',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),

              // Error message
              Obx(() {
                if (loginController.errorMessage.value.isNotEmpty) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Text(
                      loginController.errorMessage.value,
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                } else {
                  return const SizedBox.shrink(); // Empty if no error message
                }
              }),

              // Email input field
              const SizedBox(height: 32),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Email',
                        hintText: 'Enter Email',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _email = value; // Save email input value
                      },
                    ),

                    const SizedBox(height: 16),

                    // Password input field with "show password" functionality
                    Obx(
                      () => TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Password',
                          hintText: 'Password',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              showPassword.value
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              showPassword.value = !showPassword.value;
                            },
                          ),
                        ),
                        obscureText: !showPassword.value,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _password = value; // Save password input value
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // Forgot Password link
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    // Navigate to forgot password screen
                  },
                  child: const Text(
                    'Forgot Password?',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ),

              // Login button
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,  // Set the width to infinity
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState?.validate() ?? false) {
                      _formKey.currentState?.save(); // Save form data

                      // Call login controller login method
                      await loginController.loginUser(
                        email: _email!,
                        password: _password!,
                      );

                      // After login, check if login was successful
                      if (loginController.isLoggedIn.value) {
                        String? role = await loginController.getUserRole();
                        if (role == 'Seller') {
                          Get.offAllNamed('/homepageSeller');
                          print('currentUser: ${FirebaseAuth.instance.currentUser!.uid} (seller)');
                        } else if (role == 'Customer') {
                          Get.offAllNamed('/homepageCustomer');
                          print('currentUser: ${FirebaseAuth.instance.currentUser!.uid} (customer)');
                        }
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: Styles.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'LOG IN',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),

              // Register link
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('New to FarmLink? '),
                  GestureDetector(
                    onTap: () {
                      Get.toNamed('/register'); // Navigate to registration screen
                    },
                    child: const Text(
                      'Sign Up',
                      style: TextStyle(
                        color: Styles.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}