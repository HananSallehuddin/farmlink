import 'package:farmlink/controllers/CartController.dart';
import 'package:farmlink/controllers/ChatController.dart';
import 'package:farmlink/controllers/LoginController.dart';
import 'package:farmlink/controllers/ProductController.dart';
import 'package:farmlink/controllers/RatingController.dart';
import 'package:farmlink/controllers/UserController.dart';
import 'package:farmlink/controllers/AnalyticController.dart';
import 'package:farmlink/routes.dart';
import 'package:farmlink/services/NotificationService.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:farmlink/styles.dart';

Future<void> main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();
  debugPrint("Firebase initialized");

  // Set up background message handler
  FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);

  // Optimize app performance
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Initialize all controllers in the correct order
  try {
    // Initialize services first
    final notificationService = NotificationService();
    await notificationService.init();
    await notificationService.initializeNotifications();
    Get.put(notificationService, permanent: true);

    // Initialize core controllers
    Get.put(UserController(), permanent: true);
    Get.put(LoginController(), permanent: true);

    // Initialize feature controllers
    Get.put(ProductController(), permanent: true);
    Get.put(CartController(), permanent: true);
    Get.put(ChatController(), permanent: true);
    Get.put(RatingController(), permanent: true);

    // Clear any existing user data on app start
    final userController = Get.find<UserController>();
    userController.clearUserData();
    await FirebaseAuth.instance.signOut();

  } catch (e) {
    debugPrint("Error initializing controllers: $e");
  }

  runApp(const MyApp());
}

@pragma('vm:entry-point')
Future<void> _handleBackgroundMessage(RemoteMessage message) async {
  debugPrint('Handling background message: ${message.messageId}');
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'FarmLink',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Styles.primaryColor),
        useMaterial3: true,
        pageTransitionsTheme: PageTransitionsTheme(
          builders: {
            TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
      ),
      defaultTransition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 0),
      initialRoute: Routes.landing,
      getPages: Routes.pages,
      // Enable smooth scrolling
      scrollBehavior: AppScrollBehavior(),
      // Improve navigation performance
      routingCallback: (routing) {
        if (routing?.current == '/') {
          SystemChrome.setSystemUIOverlayStyle(
            SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: Brightness.dark,
            ),
          );
        }
      },
    );
  }
}

// Custom scroll behavior for smoother scrolling
class AppScrollBehavior extends ScrollBehavior {
  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const BouncingScrollPhysics();
  }
}