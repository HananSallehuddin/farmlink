import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:farmlink/styles.dart';

class bottomNavigationBarSeller extends StatelessWidget {
  final String currentRoute; //takes current route 
  bottomNavigationBarSeller({required this.currentRoute});

  @override
  Widget build(BuildContext context) {
        return BottomAppBar(
      color: Styles.secondaryColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Chat Button
          IconButton(
            icon: Icon(Icons.chat),
            color: currentRoute == '/chat' ? Styles.primaryColor : Styles.subtitleColor,
            onPressed: () {
              if (currentRoute != '/chat') {
                Get.toNamed('/chat');
              }
            },
          ),
          // Home Button
          IconButton(
            icon: Icon(Icons.home),
            color: currentRoute == '/homepageSeller' ? Styles.primaryColor : Styles.subtitleColor,
            onPressed: () {
              if (currentRoute != '/homepageSeller') {
                Get.toNamed('/homepageSeller');
              }
            },
          ),
          // Orders Button
          IconButton(
            icon: Icon(Icons.shopping_bag),
            color: currentRoute == '/orders' ? Styles.primaryColor : Styles.subtitleColor,
            onPressed: () {
              if (currentRoute != '/orders') {
                Get.toNamed('/orders');
              }
            },
          ),
          // Profile Button
          IconButton(
            icon: Icon(Icons.person),
            color: currentRoute == '/profile' ? Styles.primaryColor : Styles.subtitleColor,
            onPressed: () {
              if (currentRoute != '/profile') {
                Get.toNamed('/profile');
              }
            },
          ),
        ],
      ),
    );
  }
}