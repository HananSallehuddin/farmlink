import 'package:flutter/material.dart';
import 'package:farmlink/controllers/LoginController.dart';
import 'package:get/get.dart';
import 'package:farmlink/styles.dart';

class LoginUI extends StatelessWidget {
  const LoginUI({super.key});

  @override
  Widget build(BuildContext context) {
    //initialize LoginController using GetX
    final loginController = Get.put(LoginController());
    final _formKey = GlobalKey<FormState>(); // Form key for validation
    String? _email, _password; // Store email and password

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Logo at the top
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 40), // Adjust bottom padding for spacing
                  child: Image.asset(
                    'assets/farmlink logo wo quotes.png', // Replace with your logo path
                    width: 200,
                    height: 200,
                  ),
                ),
              ),
             const Padding(
                    padding: const EdgeInsets.only(top: 20), // Add space between logo and text
                    child: Text(
                      'Log IN',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

              // Display error message if available
              Obx(() {
                if (loginController.errorMessage.value.isNotEmpty) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Text(
                      loginController.errorMessage.value,
                      style: TextStyle(color: Colors.red),
                    ),
                  );
                } else {
                  return SizedBox.shrink(); //empty if no error message
                }
              }),

              // Email input
              TextFormField(
                decoration: InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    print('Email validation failed: Empty');
                    return 'Please enter your email';
                  }
                  return null;
                },
                onSaved: (value) {
                  _email = value; // Save email input value
                },
              ),
              // Password input
              TextFormField(
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) {
                  print('Validating password: $value');
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
                onSaved: (value) {
                  _password = value; // Save password input value
                },
              ),
              SizedBox(height: 20),

              // Login button
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState?.validate() ?? false) {
                    _formKey.currentState?.save(); // Save form data
                    print('Attempting login with email: $_email and password: $_password');

                    // Call login controller login method
                    await loginController.loginUser(
                      email: _email!,
                      password: _password!,
                    );

                    // After login, check if login was successful
                    if (loginController.isLoggedIn.value) {
                      print('Login successful. Fetching role...');
                      // Check role and navigate accordingly
                      String? role = await loginController.getUserRole();
                      print('Role retrieved: $role');

                      if (role == 'Seller') {
                        Get.offAllNamed('/homepageSeller');
                        print('Navigating to /homepageSeller');
                      } else if (role == 'Customer'){
                        Get.offAllNamed('/homepageCustomer');
                        print('Navigating to /homepageCustomer');
                      } else {
                        print('Error: Role is not recognized or null');
                      }
                    } else {
                      print('Login failed or email not verified');
                    }
                  } else {
                    print('Form validation failed');
                  }
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white, backgroundColor: Styles.secondaryColor,
                ),
                child: Text('Login'),
              ),

              SizedBox(height: 20),

              // Navigate to registration page
              TextButton(
                onPressed: () {
                  Get.toNamed('/register'); // Navigate to registration screen
                },
                child: Text('Don\'t have an account? Register'),
              ),
            ],
          ),
       )
        ),
      ),
    );
  }
}