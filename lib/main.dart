import 'package:farmlink/controllers/CartController.dart';
import 'package:farmlink/controllers/LoginController.dart';
import 'package:farmlink/controllers/OrderController.dart';
import 'package:farmlink/controllers/ProductController.dart';
import 'package:farmlink/controllers/UserController.dart';
import 'package:farmlink/routes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:farmlink/styles.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  print("Firebase initialized");
  Get.put(UserController());
  Get.put(LoginController());
  Get.put(ProductController());
  Get.put(CartController());
  Get.put(OrderController());

  runApp(const MyApp());
} 

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'FarmLink',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Styles.primaryColor),
        useMaterial3: true,
      ),
      initialRoute: Routes.homepageCustomer,
      getPages: Routes.pages,
    );
  }
}

