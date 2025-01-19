import 'package:farmlink/bottomNaviBarCustomer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:farmlink/controllers/UserController.dart';
import 'package:farmlink/controllers/LoginController.dart';
import 'package:farmlink/styles.dart';

class CustProfileUI extends StatefulWidget {
  @override
  _CustProfileUIState createState() => _CustProfileUIState();
}

class _CustProfileUIState extends State<CustProfileUI> with AutomaticKeepAliveClientMixin {
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

  Future<void> _showDeleteAccountConfirmation() async {
    final TextEditingController passwordController = TextEditingController();
    final RxBool isDeletingAccount = false.obs;

    await Get.dialog(
      AlertDialog(
        title: Text('Delete Account'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'This action cannot be undone. Please enter your password to confirm.',
              style: TextStyle(color: Colors.red),
            ),
            SizedBox(height: 16),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel'),
          ),
          Obx(() => ElevatedButton(
            onPressed: isDeletingAccount.value
                ? null
                : () async {
                    try {
                      isDeletingAccount.value = true;
                      await loginController.deleteAccount(passwordController.text);
                    } catch (e) {
                      Get.snackbar(
                        'Error',
                        'Failed to delete account',
                        backgroundColor: Colors.red,
                        colorText: Colors.white,
                      );
                    } finally {
                      isDeletingAccount.value = false;
                    }
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: isDeletingAccount.value
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    'Delete Account',
                    style: TextStyle(color: Colors.white),
                  ),
          )),
        ],
      ),
      barrierDismissible: false,
    );
  }

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
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Get.toNamed('editprofile'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Styles.primaryColor,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(  
                      'Edit Profile',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                    ),
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
                  child: TextButton(
                    onPressed: _showDeleteAccountConfirmation,
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      foregroundColor: Colors.red,
                    ),
                    child: Text(
                      'Delete Account',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
      bottomNavigationBar: bottomNavigationBarCustomer(currentRoute: '/custprofile'),
    );
  }

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    super.dispose();
  }
}