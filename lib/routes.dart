import 'package:farmlink/views/Customer/addressFormUI.dart';
import 'package:farmlink/views/Customer/addressList.dart';
import 'package:farmlink/views/Customer/checkout.dart';
import 'package:farmlink/views/Customer/viewCartUI.dart';
import 'package:farmlink/views/Customer/viewProduceUI.dart';
import 'package:farmlink/views/Seller/productFormUI.dart';
import 'package:farmlink/views/Seller/recycleUI.dart';
import 'package:farmlink/views/Seller/updateProduceUI.dart';
import 'package:get/get.dart';
import 'package:farmlink/views/LandingPage.dart';
import 'package:farmlink/views/RegistrationUI.dart';
import 'package:farmlink/views/LoginUI.dart';   
import 'package:farmlink/views/Seller/%20HomepageSeller.dart';
import 'package:farmlink/views/Customer/HomepageCustomer.dart';

class Routes{
  //Define route name as constants
  static const String landing = '/landing';
  static const String login = '/login';
  static const String register = '/register';
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
    GetPage(
      name: updateProduce,
      page: () => updateProduceUI(),
    ),
    GetPage(
      name: viewProduce,
      page: () => viewProduceUI(),
    ),
    GetPage(
      name: viewCart,
      page: () => viewCartUI(),
    ),
    GetPage(
      name: checkout,
      page: () => checkoutUI(),
    ),
    GetPage(
      name: addressForm,
      page: () => addressFormUI(),
    ),
    GetPage(
      name: addressList,
      page: () => addressListUI(),
    ),
  ];
}