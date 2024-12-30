import 'package:farmlink/views/productFormUI.dart';
import 'package:farmlink/views/recycleUI.dart';
import 'package:get/get.dart';
import 'package:farmlink/views/LandingPage.dart';
import 'package:farmlink/views/RegistrationUI.dart';
import 'package:farmlink/views/LoginUI.dart';   
import 'package:farmlink/views/ HomepageSeller.dart';
import 'package:farmlink/views/HomepageCustomer.dart';

class Routes{
  //Define route name as constants
  static const String landing = '/landing';
  static const String login = '/login';
  static const String register = '/register';
  static const String homepageSeller = '/homepageSeller';
  static const String homepageCustomer = '/homepageCustomer';
  static const String productForm = '/productForm';
  static const String recyclePage = '/recyclePage';

  //Map routes to pages
  static final pages = [
    //landing page route
    GetPage(
      name: landing,
      page: () => LandingPage(),
    ),
    GetPage(
      name: login,
      page: () => LoginUI(),
    ),
    GetPage(
      name: register,
      page: () => RegistrationUI(),
    ),
    GetPage(
      name: homepageSeller,
      page: () => HomepageSeller(),
    ),
    GetPage(
      name: homepageCustomer,
      page: () => HomepageCustomer(),
    ),
    GetPage(
      name: productForm,
      page: () => productFormUI(),
    ),
    GetPage(
      name: recyclePage,
      page: () => recycleUI(),
    ),
  ];
}