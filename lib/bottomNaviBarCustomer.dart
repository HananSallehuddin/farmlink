import 'package:farmlink/controllers/UserController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:farmlink/styles.dart';

class bottomNavigationBarCustomer extends StatelessWidget {
  final String currentRoute; //takes current route 
  bottomNavigationBarCustomer({required this.currentRoute});
  
  @override
  Widget build(BuildContext context) {
        return BottomAppBar(
      color: Styles.primaryColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Home Button
          IconButton(
            icon: Icon(Icons.home),
            color: currentRoute == '/homepageCustomer' ? Colors.white : Styles.subtitleColor,
            onPressed: () {
              if (currentRoute != '/homepageCustomer') {
                Get.toNamed('/homepageCustomer');
              }
            },
          ),
          //chat button
         IconButton(
              icon: Icon(Icons.chat),
              color: Styles.subtitleColor,
              onPressed: () {
                Get.toNamed('/chat');
              },
            ),
          
          // Orders Button
          IconButton(
            icon: Icon(Icons.receipt_long),
            color: currentRoute == '/orderList' ? Colors.white : Styles.subtitleColor,
            onPressed: () {
              if (currentRoute != '/orderList') {
                Get.toNamed('/orderList');
              }
            },
          ),

         // Logout Button (replacing Profile Button)
          IconButton(
            icon: Icon(Icons.exit_to_app),  // Logout icon
            color: currentRoute == '/login' ? Colors.white : Styles.subtitleColor,
            onPressed: () async {
              Get.find<UserController>().logout(); // Logout method
            },
          ),
        ],
      ),
    );
  }
}

