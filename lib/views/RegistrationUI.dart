import 'package:farmlink/styles.dart';
import 'package:flutter/material.dart';
import 'package:farmlink/controllers/RegistrationController.dart';
import 'package:get/get.dart';

class RegistrationUI extends StatefulWidget {
  const RegistrationUI({super.key});

  @override
  State<RegistrationUI> createState() => _RegistrationUIState();
}

class _RegistrationUIState extends State<RegistrationUI> {
  final RegistrationController _controller = RegistrationController();
  final _formKey = GlobalKey<FormState>();
  String username = '';
  String password = '';
  String confirmPassword = '';
  bool isPasswordVisible = false;
  String email = '';
  String role = '';
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top:30),
                child: Image.asset(
                'assets/farmlink logo wo quotes.png',
                width: 200,
                height: 200,
              ),
            ),
            ),

            const Text(
                'Register your account',
                style: TextStyle(
                  fontWeight: FontWeight.bold,  // Bold
                  fontSize: 20,                
                ),
              ),
            SizedBox(height: 20),

            //registration form
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    //username field
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Username',
                        labelStyle: Styles.bodyText1,
                        ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your username';
                        }
                        return null;
                      },
                      onSaved: (value) => username = value!,
                    ),
                    SizedBox(height: 16),
                    //email field
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        labelStyle: Styles.bodyText1,
                        ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$").hasMatch(value)) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                      onSaved: (value) => email = value!,
                    ),
                    SizedBox(height: 16),
                    //password field
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        labelStyle: Styles.bodyText1,
                        ),
                      obscureText: !isPasswordVisible,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                      onSaved: (value) => password = value!,
                    ),
                    SizedBox(height: 8),
               
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            isPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Styles.textColor,
                          ),
                          onPressed: () {
                            setState(() {
                              isPasswordVisible = !isPasswordVisible;
                            });
                          },
                          ),
                          Text('Show Password',
                          style: Styles.bodyText1,
                          ),
                      ],
                    ),
                    SizedBox(height: 16),
                //Role selection button
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Select Role:'),
                        SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Radio<String>(
                              value: 'Seller',
                              groupValue: role, 
                              onChanged: (value) {
                                setState(() {
                                  role = value!;
                                });
                              },
                            ),
                            Text('Seller'),
                          ],
                        ),
                        Row(
                          children: [
                            Radio<String>(
                              value: 'Customer',
                              groupValue: role,
                              onChanged: (value) {
                                setState(() {
                                  role = value!;
                                });
                              },
                            ),
                            Text('Customer'),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
              
                //Register Button
                    ElevatedButton(
                      onPressed: _registerUser, 
                      child: Text('Sign up'),
                    ),
                    SizedBox(height: 16),
              
                    //Login Link
                    Center(
                      child: TextButton(
                        onPressed: () {
                          Get.toNamed('/login');
                        },
                        child: Text(
                          'Already have an account? Log in',
                          style: TextStyle(fontSize: 16, color: Styles.buttonColor),
                        ),
                      ),
                    ),
                  ],
              ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
  void _registerUser() async {
    if(_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      if (role.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please select a role'), backgroundColor: Styles.buttonColor),
          );
          return;
      }

      String? errorMessage = await _controller.registerUser(
        username: username,
        email: email,
        password: password,
        role: role,
      );

      if (errorMessage == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration successful'), backgroundColor: Colors.green),
        );
        Get.toNamed('/login');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
        );
      }
    }
  }
} 