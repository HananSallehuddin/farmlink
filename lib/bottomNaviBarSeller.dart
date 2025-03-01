import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:farmlink/styles.dart';

class bottomNavigationBarSeller extends StatelessWidget {
  final String currentRoute; //takes current route 
  bottomNavigationBarSeller({required this.currentRoute});

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
            color: currentRoute == '/homepageSeller' ? Colors.white : Styles.subtitleColor,
            onPressed: () {
              if (currentRoute != '/homepageSeller') {
                Get.toNamed('/homepageSeller');
              }
            },
          ),
          // Chat Button
          IconButton(
            icon: Icon(Icons.chat),
            color: currentRoute == '/chat' ? Colors.white : Styles.subtitleColor,
            onPressed: () {
              if (currentRoute != '/chat') {
                Get.toNamed('/chat');
              }
            },
          ),
          // recycle produce button
          IconButton(
            icon: Icon(Icons.recycling),
            color: currentRoute == '/recyclePage' ? Colors.white : Styles.subtitleColor,
            onPressed: () {
              if (currentRoute != '/recyclePage') {
                Get.toNamed('/recyclePage');
              }
            },
          ),
          // Orders Button
          IconButton(
            icon: Icon(Icons.receipt_long),
            color: currentRoute == '/orders' ? Colors.white : Styles.subtitleColor,
            onPressed: () {
              if (currentRoute != '/orders') {
                Get.toNamed('/orders');
              }
            },
          ),
          // Profile Button
          IconButton(
            icon: Icon(Icons.person),
            color: currentRoute == '/login' ? Colors.white : Styles.subtitleColor,
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