import 'package:farmlink/bottomNaviBarCustomer.dart';
import 'package:farmlink/controllers/CartController.dart';
import 'package:farmlink/controllers/UserController.dart';
import 'package:farmlink/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';

class checkoutUI extends StatefulWidget {
  @override
  _checkoutUIState createState() => _checkoutUIState();
}

class _checkoutUIState extends State<checkoutUI> with AutomaticKeepAliveClientMixin {
  final CartController cartController = Get.find<CartController>();
  final UserController userController = Get.find<UserController>();
  final RxBool isProcessing = false.obs;
  final ScrollController _scrollController = ScrollController();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    //userController.fetchAddresses();
  }

  Future<void> _handlePlaceOrder() async {
    if (userController.selectedAddress.value == null) {
      Get.snackbar(
        'Error',
        'Please select a delivery address',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isProcessing.value = true;
      await cartController.processCheckout();
      Get.offAllNamed('/orders');
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isProcessing.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    // ignore: deprecated_member_use
    return Scaffold(
        appBar: AppBar(
          title: const Text('Checkout'),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Get.back(),
          ),
        ),
        body: Obx(() {
          if (cartController.cart.value.produces.isEmpty) {
            return _buildEmptyCart();
          }
          var selectedAddress = userController.selectedAddress.value;
          if (selectedAddress == null) {
          return Center(
            child: ElevatedButton(
              onPressed: () {
                Get.toNamed('addressList');
              },
              child: const Text('Add new address'),
            ),
          );
        }

          return SingleChildScrollView(
            controller: _scrollController,
            physics: isProcessing.value 
                ? NeverScrollableScrollPhysics() 
                : AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //_buildDeliveryAddress(),
                Text('Delivery Address:', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: (){
                  Get.toNamed('addressList');
                },
                child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Styles.primaryColor, 
                  border: Border.all(color: Colors.green.shade50, width: 2), 
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            selectedAddress.address,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 6),
                          Text('${selectedAddress.city}, ${selectedAddress.state}, ${selectedAddress.zipCode}'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              ),
              const SizedBox(height: 20),
                _buildOrderSummary(),
                _buildPaymentMethod(),
              ],
            ),
          );
        }),
        bottomNavigationBar: _buildBottomBar(),
      
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Your cart is empty',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Get.offAllNamed('/homepageCustomer'),
            child: Text('Continue Shopping'),
            style: Styles.primaryButtonStyle,
          ),
        ],
      ),
    );
  }

//   Widget _buildDeliveryAddress() {
//     return Container(
//       padding: EdgeInsets.all(16),
//       color: Colors.white,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 'Delivery Address',
//                 style: Styles.header3,
//               ),
//               TextButton(
//                 onPressed: isProcessing.value ? null : () => Get.toNamed('/addressList'),
//                 child: Text('Change'),
//                 style: TextButton.styleFrom(
//                   foregroundColor: Styles.primaryColor,
//                 ),
//               ),
//             ],
//           ),
//           SizedBox(height: 8),
//           Obx(() {
//             final selectedAddress = userController.selectedAddress.value;
//             if (selectedAddress == null) {
//               return Container(
//                 padding: EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   border: Border.all(color: Colors.grey.shade300),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Row(
//                   children: [
//                     Icon(Icons.add_location_alt_outlined, color: Colors.grey),
//                     SizedBox(width: 16),
//                     Text(
//                       'Add delivery address',
//                       style: TextStyle(color: Colors.grey),
//                     ),
//                   ],
//                 ),
//               );
//             }

//             return Container(
//               padding: EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 border: Border.all(color: Styles.primaryColor),
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     selectedAddress.address,
//                     style: TextStyle(fontWeight: FontWeight.bold),
//                   ),
//                   SizedBox(height: 4),
//                   Text(
//                     '${selectedAddress.city}, ${selectedAddress.state} ${selectedAddress.zipCode}',
//                     style: TextStyle(color: Colors.grey.shade700),
//                   ),
//                 ],
//               ),
//             );
//           }),
//         ],
//       ),
//     );
//   }

  Widget _buildOrderSummary() {
    return Container(
      padding: EdgeInsets.all(16),
      color: Colors.white,
      margin: EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Summary',
            style: Styles.header3,
          ),
          SizedBox(height: 16),
          ...cartController.cart.value.produces.map((produce) {
            final quantity = cartController.cart.value.quantity[produce.pid] ?? 0;
            final itemTotal = produce.price * quantity;

            return Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: produce.imageUrls[0],
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey[200],
                        child: Center(child: CircularProgressIndicator()),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[200],
                        child: Icon(Icons.error),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          produce.productName,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${quantity}x @ RM${produce.price.toStringAsFixed(2)}',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'RM${itemTotal.toStringAsFixed(2)}',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            );
          }).toList(),
          Divider(height: 32),
          _buildPriceSummary(),
        ],
      ),
    );
  }

  Widget _buildPriceSummary() {
    final subtotal = cartController.calculateTotalPrice();
    //final deliveryFee = 5.00; // Fixed delivery fee
    //final total = subtotal + deliveryFee;
    final total = subtotal;

    return Column(
      children: [
        _buildPriceRow('Subtotal', subtotal),
       // _buildPriceRow('Delivery Fee', deliveryFee),
        SizedBox(height: 8),
        _buildPriceRow('Total', total, isTotal: true),
      ],
    );
  }

  Widget _buildPriceRow(String label, double amount, {bool isTotal = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 16 : 14,
            ),
          ),
          Text(
            'RM${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 16 : 14,
              color: isTotal ? Styles.primaryColor : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethod() {
    return Container(
      padding: EdgeInsets.all(16),
      color: Colors.white,
      margin: EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment Method',
            style: Styles.header3,
          ),
          SizedBox(height: 16),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Styles.primaryColor),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.money, color: Styles.primaryColor),
                SizedBox(width: 16),
                Text(
                  'Cash on Delivery',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Spacer(),
                Icon(Icons.check_circle, color: Styles.primaryColor),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Payment',
                      style: TextStyle(color: Colors.grey),
                    ),
                    Text(
                      'RM${(cartController.calculateTotalPrice()).toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Styles.primaryColor,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  width: 200,
                  child: Obx(() => ElevatedButton(
                    onPressed: isProcessing.value ? null : _handlePlaceOrder,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Styles.primaryColor,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: isProcessing.value
                        ? SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            'Place Order',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  )),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}