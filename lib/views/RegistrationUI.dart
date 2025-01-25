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
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              // Logo
              Padding(
                padding: const EdgeInsets.only(top: 40.0, bottom: 20.0),
                child: Image.asset(
                  'assets/farmlink logo wo quotes.png',
                  width: 150,
                  height: 150,
                ),
              ),

              // Header
              const Text(
                'Create your account',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
              const Text(
                'Join FarmLink to connect with local produce!',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 30),

              // Registration Form
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Username
                    TextFormField(
                      decoration: _buildInputDecoration(
                        'Username',
                        'Choose a username',
                        Icons.person,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a username';
                        }
                        return null;
                      },
                      onSaved: (value) => username = value!,
                    ),
                    const SizedBox(height: 16),

                    // Email
                    TextFormField(
                      decoration: _buildInputDecoration(
                        'Email',
                        'Enter your email',
                        Icons.email,
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!GetUtils.isEmail(value)) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                      onSaved: (value) => email = value!,
                    ),
                    const SizedBox(height: 16),

                    // Password
                    TextFormField(
                      obscureText: !isPasswordVisible,
                      decoration: _buildInputDecoration(
                        'Password',
                        'Enter password',
                        Icons.lock,
                        suffixIcon: IconButton(
                          icon: Icon(
                            isPasswordVisible 
                              ? Icons.visibility 
                              : Icons.visibility_off,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              isPasswordVisible = !isPasswordVisible;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                      onChanged: (value) => password = value,
                      onSaved: (value) => password = value!,
                      ),
                    const SizedBox(height: 16),

                    // Confirm Password
                    TextFormField(
                      obscureText: !isPasswordVisible,
                      decoration: _buildInputDecoration(
                        'Confirm Password',
                        'Confirm your password',
                        Icons.lock,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please confirm your password';
                        }
                        if (value != password) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                      onSaved: (value) => confirmPassword = value!,
                    ),
                    const SizedBox(height: 24),

                    // Role Selection
                    Text(
                      'Select your role:',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: _buildRoleCard(
                            'Customer',
                            Icons.shopping_cart,
                            role == 'Customer',
                            () => setState(() => role = 'Customer'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildRoleCard(
                            'Seller',
                            Icons.store,
                            role == 'Seller',
                            () => setState(() => role = 'Seller'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Sign Up Button
                    SizedBox(
                      width: double.infinity,
                      child: Obx(() => ElevatedButton(
                        onPressed: _controller.isLoading.value
                            ? null
                            : () => _registerUser(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Styles.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: _controller.isLoading.value
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                                'SIGN UP',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      )),
                    ),
                    const SizedBox(height: 16),

                    // Login Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Already have an account? '),
                        GestureDetector(
                          onTap: () => Get.toNamed('/login'),
                          child: Text(
                            'Log In',
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard(String title, IconData icon, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? Styles.primaryColor.withOpacity(0.1) : Colors.white,
          border: Border.all(
            color: isSelected ? Styles.primaryColor : Colors.grey.shade300,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: isSelected ? Styles.primaryColor : Colors.grey,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? Styles.primaryColor : Colors.grey[700],
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String label, String hint, IconData icon, {Widget? suffixIcon}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon),
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide(color: Colors.grey.shade400),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide(color: Styles.primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
      filled: true,
      fillColor: Colors.grey.shade50,
    );
  }

  void _registerUser() async {
    if (role.isEmpty) {
      Get.snackbar(
        'Error',
        'Please select a role (Customer or Seller)',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      
      await _controller.registerUser(
        username: username,
        email: email,
        password: password,
        role: role,
      );

      if (_controller.errorMessage.isNotEmpty) {
        Get.snackbar(
          'Error',
          _controller.errorMessage.value,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }
  }
}