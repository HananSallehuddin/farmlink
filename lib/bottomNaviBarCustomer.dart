import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:farmlink/styles.dart';

class bottomNavigationBarCustomer extends StatelessWidget {
  final String currentRoute; //takes current route 
  bottomNavigationBarCustomer({required this.currentRoute});
  
  @override
  Widget build(BuildContext context) {
        return BottomAppBar(
      color: Styles.secondaryColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          //chat button
         IconButton(
              icon: Icon(Icons.chat),
              color: Styles.subtitleColor,
              onPressed: () {
                Get.toNamed('/chat');
              },
            ),
          // Home Button
          IconButton(
            icon: Icon(Icons.home),
            color: currentRoute == '/homepageCustomer' ? Styles.primaryColor : Styles.subtitleColor,
            onPressed: () {
              if (currentRoute != '/homepageCustomer') {
                Get.toNamed('/homepageCustomer');
              }
            },
          ),

          // Profile Button
          IconButton(
            icon: Icon(Icons.person),
            color: currentRoute == '/login' ? Styles.primaryColor : Styles.subtitleColor,
            onPressed: () {
              if (currentRoute != '/login') {
                Get.toNamed('/login');
              }
            },
          ),
        ],
      ),
    );
  }
}

