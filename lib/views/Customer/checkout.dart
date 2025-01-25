import 'package:farmlink/bottomNaviBarCustomer.dart';
import 'package:farmlink/controllers/CartController.dart';
import 'package:farmlink/controllers/UserController.dart';
import 'package:farmlink/models/UserModel.dart';
import 'package:farmlink/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';

class checkoutUI extends StatefulWidget {
  @override
  _checkoutUIState createState() => _checkoutUIState();
}

class _checkoutUIState extends State<checkoutUI> {
  final CartController cartController = Get.find<CartController>();
  final UserController userController = Get.find<UserController>();
  final ScrollController _scrollController = ScrollController();
  final RxBool isProcessing = false.obs;

  @override
  void initState() {
    super.initState();
    userController.fetchAddresses();
  }

  void _showAddressActions(Address address) {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Address Options',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            ListTile(
              leading: Icon(Icons.edit),
              title: Text('Edit Address'),
              onTap: () {
                Get.back();
                _showEditAddressDialog(address);
              },
            ),
            ListTile(
              leading: Icon(Icons.delete, color: Colors.red),
              title: Text('Delete Address', style: TextStyle(color: Colors.red)),
              onTap: () {
                Get.back();
                _showDeleteConfirmation(address);
              },
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  void _showEditAddressDialog(Address address) {
    final TextEditingController addressController = TextEditingController(text: address.address);
    final TextEditingController cityController = TextEditingController(text: address.city);
    final TextEditingController stateController = TextEditingController(text: address.state);
    final TextEditingController zipCodeController = TextEditingController(text: address.zipCode);

    Get.dialog(
      AlertDialog(
        title: Text('Edit Address'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: addressController,
                decoration: InputDecoration(labelText: 'Address'),
              ),
              TextField(
                controller: cityController,
                decoration: InputDecoration(labelText: 'City'),
              ),
              TextField(
                controller: stateController,
                decoration: InputDecoration(labelText: 'State'),
              ),
              TextField(
                controller: zipCodeController,
                decoration: InputDecoration(labelText: 'ZIP Code'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newAddress = Address(
                address: addressController.text,
                city: cityController.text,
                state: stateController.text,
                zipCode: zipCodeController.text,
                reference: address.reference,
              );
              await userController.updateAddress(address, newAddress);
              Get.back();
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(Address address) {
    Get.dialog(
      AlertDialog(
        title: Text('Delete Address'),
        content: Text('Are you sure you want to delete this address?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await userController.deleteAddress(address);
              Get.back();
            },
            child: Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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

        return SingleChildScrollView(
          controller: _scrollController,
          physics: isProcessing.value
              ? NeverScrollableScrollPhysics()
              : AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAddressSection(),
              _buildOrderSummary(),
              _buildPaymentMethod(),
            ],
          ),
        );
      }),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildAddressSection() {
    return Container(
      padding: EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Delivery Address',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () => Get.toNamed('/addressForm'),
                child: Text('Add New'),
              ),
            ],
          ),
          SizedBox(height: 8),
          Obx(() => Column(
            children: userController.addresses.map((address) {
              bool isSelected = cartController.selectedAddress.value == address;
              return GestureDetector(
                onTap: () => cartController.updateCartAddress(address),
                onLongPress: () => _showAddressActions(address),
                child: Container(
                  margin: EdgeInsets.only(bottom: 8),
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: isSelected ? Styles.primaryColor : Colors.grey.shade300,
                      width: isSelected ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              address.address,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '${address.city}, ${address.state}',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                            Text(
                              address.zipCode,
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                      if (isSelected)
                        Icon(Icons.check_circle, color: Styles.primaryColor),
                    ],
                  ),
                ),
              );
            }).toList(),
          )),
        ],
      ),
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
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
    final total = subtotal;
    return Column(
      children: [
        _buildPriceRow('Subtotal', subtotal),
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
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                      'RM${cartController.calculateTotalPrice().toStringAsFixed(2)}',
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
                    onPressed: isProcessing.value ? null : () async {
                      if (cartController.selectedAddress.value == null) {
                        Get.snackbar(
                          'Error',
                          'Please select a delivery address',
                          backgroundColor: Colors.red,
                          colorText: Colors.white,
                        );
                        return;
                      }
                      try {
                        isProcessing.value = true;
                        await cartController.processCheckout();
                      } finally {
                        isProcessing.value = false;
                      }
                    },
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