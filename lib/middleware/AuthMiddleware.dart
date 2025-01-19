import 'package:farmlink/controllers/UserController.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:farmlink/routes.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  int? get priority => 1;

  @override
  RouteSettings? redirect(String? route) {
    // Check if user is logged in
    if (FirebaseAuth.instance.currentUser == null) {
      // If not logged in, redirect to login page
      return const RouteSettings(name: Routes.login);
    }

    // If logged in but email not verified
    if (!FirebaseAuth.instance.currentUser!.emailVerified) {
      FirebaseAuth.instance.signOut();
      Get.snackbar(
        'Email Not Verified',
        'Please verify your email before accessing this feature.',
        duration: const Duration(seconds: 5),
      );
      return const RouteSettings(name: Routes.login);
    }

    // Allow access to the requested route
    return null;
  }
}

class RoleMiddleware extends GetMiddleware {
  final String requiredRole;

  RoleMiddleware(this.requiredRole);

  @override
  int? get priority => 2;

  @override
  RouteSettings? redirect(String? route) {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return const RouteSettings(name: Routes.login);
    }

    // Get user role from UserController
    final userController = Get.find<UserController>();
    final currentRole = userController.currentUser.value?.role;

    if (currentRole != requiredRole) {
      return RouteSettings(
        name: currentRole == 'Seller' ? Routes.homepageSeller : Routes.homepageCustomer
      );
    }

    Get.put(currentRole, tag: 'currentRole');
    return null;
  }
}