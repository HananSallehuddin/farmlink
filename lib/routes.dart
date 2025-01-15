import 'package:farmlink/views/Customer/addressFormUI.dart';
import 'package:farmlink/views/Customer/addressList.dart';
import 'package:farmlink/views/Customer/checkout.dart';
import 'package:farmlink/views/Customer/orderListUI.dart';
import 'package:farmlink/views/Customer/rateProduceFormUI.dart';
import 'package:farmlink/views/Customer/ratingList.dart';
import 'package:farmlink/views/Customer/trackOrderUI.dart';
import 'package:farmlink/views/Customer/viewCartUI.dart';
import 'package:farmlink/views/Customer/viewProduceUI.dart';
import 'package:farmlink/views/Seller/analyticUI.dart';
import 'package:farmlink/views/Seller/productFormUI.dart';
import 'package:farmlink/views/Seller/recycleUI.dart';
import 'package:farmlink/views/Seller/sellerOrderListUI.dart';
import 'package:farmlink/views/Seller/updateOrderStatusUI.dart';
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
  static const String orderList = '/orderList';
  static const String sellerOrderList = '/sellerOrderList';
  static const String updateOrderStatus = '/updateOrderStatus';
  static const String trackOrder = '/trackOrder';
  static const String analytic = '/analytic';
  static const String ratingList = '/ratingList';
  static const String rateProduce = '/rateProduce';



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
    GetPage(
      name: orderList,
      page: () => orderListUI(),
    ),
    GetPage(
      name: sellerOrderList,
      page: () => sellerOrderListUI(),
    ),
    GetPage(
      name: updateOrderStatus,
      page: () => updateOrderStatusUI(),
    ),
    GetPage(
      name: trackOrder,
      page: () => trackOrderUI(),
    ),
    GetPage(
      name: analytic,
      page: () => analyticUI(),
    ),
    GetPage(
      name: ratingList,
      page: () => ratingListUI(),
    ),
    GetPage(
      name: rateProduce,
      page: () => rateProduceFormUI(),
    ),
  ];
}