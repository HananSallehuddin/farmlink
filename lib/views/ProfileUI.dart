import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:farmlink/controllers/UserController.dart';
import 'package:farmlink/controllers/LoginController.dart';
import 'package:farmlink/styles.dart';

class ProfileUI extends StatefulWidget {
  @override
  _ProfileUIState createState() => _ProfileUIState();
}

class _ProfileUIState extends State<ProfileUI> with AutomaticKeepAliveClientMixin {
  final UserController userController = Get.find<UserController>();
  final LoginController loginController = Get.find<LoginController>();
  final _formKey = GlobalKey<FormState>();
  
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final RxBool isProcessing = false.obs;
  
  @override
  bool get wantKeepAlive => true;
  
  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    final user = userController.currentUser.value;
    if (user != null) {
      usernameController.text = user.username;
      emailController.text = user.email;
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      isProcessing.value = true;
      await userController.updateUserProfile(
        username: usernameController.text,
      );
      Get.snackbar(
        'Success',
        'Profile updated successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update profile',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isProcessing.value = false;
    }
  }

  Future<void> _showChangePasswordDialog() async {
    final TextEditingController currentPasswordController = TextEditingController();
    final TextEditingController newPasswordController = TextEditingController();
    final TextEditingController confirmPasswordController = TextEditingController();
    final RxBool isChangingPassword = false.obs;

    await Get.dialog(
      AlertDialog(
        title: Text('Change Password'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: currentPasswordController,
                decoration: InputDecoration(labelText: 'Current Password'),
                obscureText: true,
              ),
              SizedBox(height: 8),
              TextField(
                controller: newPasswordController,
                decoration: InputDecoration(labelText: 'New Password'),
                obscureText: true,
              ),
              SizedBox(height: 8),
              TextField(
                controller: confirmPasswordController,
                decoration: InputDecoration(labelText: 'Confirm New Password'),
                obscureText: true,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel'),
          ),
          Obx(() => ElevatedButton(
            onPressed: isChangingPassword.value
                ? null
                : () async {
                    if (newPasswordController.text != confirmPasswordController.text) {
                      Get.snackbar('Error', 'Passwords do not match');
                      return;
                    }
                    try {
                      isChangingPassword.value = true;
                      await loginController.updatePassword(
                        currentPasswordController.text,
                        newPasswordController.text,
                      );
                      Get.back();
                      Get.snackbar(
                        'Success',
                        'Password updated successfully',
                        backgroundColor: Colors.green,
                        colorText: Colors.white,
                      );
                    } catch (e) {
                      Get.snackbar(
                        'Error',
                        'Failed to update password',
                        backgroundColor: Colors.red,
                        colorText: Colors.white,
                      );
                    } finally {
                      isChangingPassword.value = false;
                    }
                  },
            child: isChangingPassword.value
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text('Change Password'),
          )),
        ],
      ),
      barrierDismissible: false,
    );
  }

  Future<void> _showLogoutConfirmation() async {
    final RxBool isLoggingOut = false.obs;

    await Get.dialog(
      AlertDialog(
        title: Text('Logout'),
        content: Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel'),
          ),
          Obx(() => ElevatedButton(
            onPressed: isLoggingOut.value
                ? null
                : () async {
                    try {
                      isLoggingOut.value = true;
                      await loginController.signOut();
                    } finally {
                      isLoggingOut.value = false;
                    }
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: isLoggingOut.value
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    'Logout',
                    style: TextStyle(color: Colors.white),
                  ),
          )),
        ],
      ),
      barrierDismissible: false,
    );
  }

  // Future<void> _showDeleteAccountConfirmation() async {
  //   final TextEditingController passwordController = TextEditingController();
  //   final RxBool isDeletingAccount = false.obs;

  //   await Get.dialog(
  //     AlertDialog(
  //       title: Text('Delete Account'),
  //       content: Column(
  //         mainAxisSize: MainAxisSize.min,
  //         children: [
  //           Text(
  //             'This action cannot be undone. Please enter your password to confirm.',
  //             style: TextStyle(color: Colors.red),
  //           ),
  //           SizedBox(height: 16),
  //           TextField(
  //             controller: passwordController,
  //             decoration: InputDecoration(labelText: 'Password'),
  //             obscureText: true,
  //           ),
  //         ],
  //       ),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Get.back(),
  //           child: Text('Cancel'),
  //         ),
  //         Obx(() => ElevatedButton(
  //           onPressed: isDeletingAccount.value
  //               ? null
  //               : () async {
  //                   try {
  //                     isDeletingAccount.value = true;
  //                     await loginController.deleteAccount(passwordController.text);
  //                   } catch (e) {
  //                     Get.snackbar(
  //                       'Error',
  //                       'Failed to delete account',
  //                       backgroundColor: Colors.red,
  //                       colorText: Colors.white,
  //                     );
  //                   } finally {
  //                     isDeletingAccount.value = false;
  //                   }
  //                 },
  //           style: ElevatedButton.styleFrom(
  //             backgroundColor: Colors.red,
  //           ),
  //           child: isDeletingAccount.value
  //               ? SizedBox(
  //                   width: 20,
  //                   height: 20,
  //                   child: CircularProgressIndicator(
  //                     strokeWidth: 2,
  //                     valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
  //                   ),
  //                 )
  //               : Text(
  //                   'Delete Account',
  //                   style: TextStyle(color: Colors.white),
  //                 ),
  //         )),
  //       ],
  //     ),
  //     barrierDismissible: false,
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _showLogoutConfirmation,
          ),
        ],
      ),
      body: Obx(() {
        final user = userController.currentUser.value;
        
        if (user == null) {
          return Center(child: Text('No user data available'));
        }

        return SingleChildScrollView(
          padding: EdgeInsets.all(16),
          physics: AlwaysScrollableScrollPhysics(),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Hero(
                    tag: 'profile_avatar',
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Styles.primaryColor,
                      child: Text(
                        user.username[0].toUpperCase(),
                        style: TextStyle(fontSize: 40, color: Colors.white),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 24),
                Center(
                  child: Chip(
                    label: Text(
                      user.role,
                      style: TextStyle(color: Colors.white),
                    ),
                    backgroundColor: Styles.primaryColor,
                  ),
                ),
                SizedBox(height: 24),
                TextFormField(
                  controller: usernameController,
                  enabled: !isProcessing.value,
                  decoration: InputDecoration(
                    labelText: 'Username',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Username is required';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: Icon(Icons.email),
                  ),
                  readOnly: true,
                ),
                SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: Obx(() => ElevatedButton(
                    onPressed: isProcessing.value ? null : _updateProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Styles.primaryColor,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: isProcessing.value
                        ? SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            'Update Profile',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                  )),
                ),
                if (user.role == 'Customer') ...[
                  SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => Get.toNamed('/addressList'),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: Styles.primaryColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Manage Addresses',
                        style: TextStyle(fontSize: 16, color: Styles.primaryColor),
                      ),
                    ),
                  ),
                ],
                SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _showChangePasswordDialog,
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Change Password',
                      style: TextStyle(fontSize: 16, color: Colors.red),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                // SizedBox(
                //   width: double.infinity,
                //   child: TextButton(
                //     onPressed: _showDeleteAccountConfirmation,
                //     style: TextButton.styleFrom(
                //       padding: EdgeInsets.symmetric(vertical: 16),
                //       foregroundColor: Colors.red,
                //     ),
                //     child: Text(
                //       'Delete Account',
                //       style: TextStyle(fontSize: 16),
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
        );
      }),
    );
  }

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    super.dispose();
  }
}