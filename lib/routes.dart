import 'package:farmlink/views/Seller/ratingListForSellerUI.dart';
import 'package:farmlink/views/editProfileUI.dart';
import 'package:farmlink/views/Customer/addressFormUI.dart';
import 'package:farmlink/views/Customer/addressList.dart';
import 'package:farmlink/views/Customer/checkout.dart';
import 'package:farmlink/views/Customer/rateProduceFormUI.dart';
import 'package:farmlink/views/Customer/rateSellerFormUI.dart';
import 'package:farmlink/views/Customer/ratingList.dart';
import 'package:farmlink/views/Customer/viewCartUI.dart';
import 'package:farmlink/views/Customer/viewProduceUI.dart';
import 'package:farmlink/views/Seller/AnalyticUI.dart';
import 'package:farmlink/views/Seller/productFormUI.dart';
import 'package:farmlink/views/Seller/recycleUI.dart';
import 'package:farmlink/views/Seller/updateProduceUI.dart';
import 'package:farmlink/middleware/AuthMiddleware.dart';
import 'package:farmlink/views/ChatRoomListUI.dart';
import 'package:farmlink/views/ChatUI.dart';
import 'package:farmlink/views/sellerProfileUI.dart';
import 'package:get/get.dart';
import 'package:farmlink/views/LandingPage.dart';
import 'package:farmlink/views/RegistrationUI.dart';
import 'package:farmlink/views/LoginUI.dart';
import 'package:farmlink/views/Seller/HomepageSeller.dart';
import 'package:farmlink/views/Customer/HomepageCustomer.dart';
import 'package:farmlink/views/CustProfileUI.dart';
import 'package:farmlink/views/OrdersUI.dart';
import 'package:farmlink/controllers/LoginController.dart';
import 'package:farmlink/controllers/UserController.dart';

class Routes {
  static final LoginController loginController = Get.find<LoginController>();
  static final UserController userController = Get.find<UserController>();

  // Define route names as constants
  static const String landing = '/landing';
  static const String login = '/login';
  static const String register = '/register';
  static const String custprofile = '/custprofile';
  static const String sellerprofile = '/sellerprofile';

  static const String editprofile = '/editprofile';
  static const String homepageSeller = '/homepageSeller';
  static const String homepageCustomer = '/homepageCustomer';
  static const String productForm = '/productForm';
  static const String recyclePage = '/recyclePage';
  static const String updateProduce = '/updateProduce';
  static const String viewProduce = '/viewProduce';
  static const String viewCart = '/viewCart';
  static const String checkout = '/checkout';
  static const String addressForm = '/addressForm';
  static const String addressList = '/addressList';
  static const String orders = '/orders';
  static const String chatRoomList = '/chatRoomList';
  static const String chat = '/chat';

  static const String analytic = '/analytic';
  static const String ratingList = '/ratingList';
  static const String ratingListSeller = '/ratingListSeller';
  static const String rateProduce = '/rateProduce';
  static const String rateSeller = '/rateSeller';

  // Common transition settings for smoother navigation
  static const _transitionDuration = Duration(milliseconds: 150);
  static final _defaultTransition = Transition.fadeIn;

  // Map routes to pages with appropriate middleware and transitions
  static final pages = [
    GetPage(
      name: landing,
      page: () => LandingPage(),
      transition: _defaultTransition,
      transitionDuration: _transitionDuration,
    ),
    GetPage(
      name: login,
      page: () => LoginUI(),
      transition: _defaultTransition,
      transitionDuration: _transitionDuration,
    ),
    GetPage(
      name: register,
      page: () => RegistrationUI(),
      transition: _defaultTransition,
      transitionDuration: _transitionDuration,
    ),
    GetPage(
      name: custprofile,
      page: () => CustProfileUI(),
      middlewares: [AuthMiddleware()],
      transition: _defaultTransition,
      transitionDuration: _transitionDuration,
      binding: BindingsBuilder(() {
        // Ensure role is available for bottom navigation
        final role = userController.currentUser.value?.role ?? '';
        Get.put(role, tag: 'currentRole', permanent: true);
      }),
    ),
    GetPage(
      name: sellerprofile,
      page: () => sellerProfileUI(),
      middlewares: [AuthMiddleware()],
      transition: _defaultTransition,
      transitionDuration: _transitionDuration,
      binding: BindingsBuilder(() {
        // Ensure role is available for bottom navigation
        final role = userController.currentUser.value?.role ?? '';
        Get.put(role, tag: 'currentRole', permanent: true);
      }),
    ),
    GetPage(
      name: editprofile,
      page: () => editProfileUI(),
      middlewares: [AuthMiddleware()],
      transition: _defaultTransition,
      transitionDuration: _transitionDuration,
      binding: BindingsBuilder(() {
        // Ensure role is available for bottom navigation
        final role = userController.currentUser.value?.role ?? '';
        Get.put(role, tag: 'currentRole', permanent: true);
      }),
    ),
    GetPage(
      name: homepageSeller,
      page: () => HomepageSeller(),
      middlewares: [AuthMiddleware(), RoleMiddleware('Seller')],
      transition: _defaultTransition,
      transitionDuration: _transitionDuration,
    ),
    GetPage(
      name: homepageCustomer,
      page: () => HomepageCustomer(),
      middlewares: [AuthMiddleware(), RoleMiddleware('Customer')],
      transition: _defaultTransition,
      transitionDuration: _transitionDuration,
    ),
    GetPage(
      name: productForm,
      page: () => productFormUI(),
      middlewares: [AuthMiddleware(), RoleMiddleware('Seller')],
      transition: _defaultTransition,
      transitionDuration: _transitionDuration,
    ),
    GetPage(
      name: recyclePage,
      page: () => recycleUI(),
      middlewares: [AuthMiddleware(), RoleMiddleware('Seller')],
      transition: _defaultTransition,
      transitionDuration: _transitionDuration,
    ),
    GetPage(
      name: updateProduce,
      page: () => updateProduceUI(),
      middlewares: [AuthMiddleware(), RoleMiddleware('Seller')],
      transition: _defaultTransition,
      transitionDuration: _transitionDuration,
    ),
    GetPage(
      name: viewProduce,
      page: () => viewProduceUI(),
      middlewares: [AuthMiddleware()],
      transition: _defaultTransition,
      transitionDuration: _transitionDuration,
    ),
    GetPage(
      name: viewCart,
      page: () => viewCartUI(),
      middlewares: [AuthMiddleware(), RoleMiddleware('Customer')],
      transition: _defaultTransition,
      transitionDuration: _transitionDuration,
    ),
    GetPage(
      name: checkout,
      page: () => checkoutUI(),
      middlewares: [AuthMiddleware(), RoleMiddleware('Customer')],
      transition: _defaultTransition,
      transitionDuration: _transitionDuration,
    ),
    GetPage(
      name: addressForm,
      page: () => addressFormUI(),
      middlewares: [AuthMiddleware(), RoleMiddleware('Customer')],
      transition: _defaultTransition,
      transitionDuration: _transitionDuration,
    ),
    GetPage(
      name: addressList,
      page: () => addressListUI(),
      middlewares: [AuthMiddleware(), RoleMiddleware('Customer')],
      transition: _defaultTransition,
      transitionDuration: _transitionDuration,
    ),
    GetPage(
      name: orders,
      page: () => OrdersUI(),
      middlewares: [AuthMiddleware()],
      transition: _defaultTransition,
      transitionDuration: _transitionDuration,
      binding: BindingsBuilder(() {
        final role = userController.currentUser.value?.role ?? '';
        Get.put(role, tag: 'currentRole', permanent: true);
      }),
    ),
    GetPage(
      name: chatRoomList,
      page: () => ChatRoomListUI(),
      middlewares: [AuthMiddleware()],
      transition: _defaultTransition,
      transitionDuration: _transitionDuration,
      binding: BindingsBuilder(() {
        final role = userController.currentUser.value?.role ?? '';
        Get.put(role, tag: 'currentRole', permanent: true);
      }),
    ),
    GetPage(
      name: chat,
      page: () => ChatUI(),
      middlewares: [AuthMiddleware()],
      transition: _defaultTransition,
      transitionDuration: _transitionDuration,
      binding: BindingsBuilder(() {
        final role = userController.currentUser.value?.role ?? '';
        Get.put(role, tag: 'currentRole', permanent: true);
      }),
    ),
    GetPage(
      name: analytic,
      page: () => analyticUI(),
      middlewares: [AuthMiddleware()],
      transition: _defaultTransition,
      transitionDuration: _transitionDuration,
      binding: BindingsBuilder(() {
        final role = userController.currentUser.value?.role ?? '';
        Get.put(role, tag: 'currentRole', permanent: true);
      }),
    ),
    GetPage(
      name: ratingList,
      page: () => ratingListUI(),
      middlewares: [AuthMiddleware()],
      transition: _defaultTransition,
      transitionDuration: _transitionDuration,
      binding: BindingsBuilder(() {
        final role = userController.currentUser.value?.role ?? '';
        Get.put(role, tag: 'currentRole', permanent: true);
      }),
    ),
    GetPage(
      name: ratingListSeller,
      page: () => ratingListForSellerUI(),
      middlewares: [AuthMiddleware()],
      transition: _defaultTransition,
      transitionDuration: _transitionDuration,
      binding: BindingsBuilder(() {
        final role = userController.currentUser.value?.role ?? '';
        Get.put(role, tag: 'currentRole', permanent: true);
      }),
    ),
    GetPage(
      name: rateProduce,
      page: () => rateProduceFormUI(),
      middlewares: [AuthMiddleware()],
      transition: _defaultTransition,
      transitionDuration: _transitionDuration,
      binding: BindingsBuilder(() {
        final role = userController.currentUser.value?.role ?? '';
        Get.put(role, tag: 'currentRole', permanent: true);
      }),
    ),
    GetPage(
      name: rateSeller,
      page: () => rateSellerFormUI(),
      middlewares: [AuthMiddleware()],
      transition: _defaultTransition,
      transitionDuration: _transitionDuration,
      binding: BindingsBuilder(() {
        final role = userController.currentUser.value?.role ?? '';
        Get.put(role, tag: 'currentRole', permanent: true);
      }),
    ),

  ];

  // Helper methods for navigation with improved state management
  static Future<void> goToHomepage(String role) async {
    final route = role == 'Seller' ? homepageSeller : homepageCustomer;
    await Get.offAllNamed(route);
  }

  static void goToOrders() {
    final role = userController.currentUser.value?.role ?? '';
    Get.put(role, tag: 'currentRole', permanent: true);
    Get.toNamed(orders);
  }

  static void goToChatRoomList() {
    final role = userController.currentUser.value?.role ?? '';
    Get.put(role, tag: 'currentRole', permanent: true);
    Get.toNamed(chatRoomList);
  }

  static void goToChat(String roomId) {
    final role = userController.currentUser.value?.role ?? '';
    Get.put(role, tag: 'currentRole', permanent: true);
    Get.toNamed(chat, arguments: roomId);
  }
}