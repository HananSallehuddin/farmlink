import 'package:farmlink/bottomNaviBarCustomer.dart';
import 'package:farmlink/controllers/CartController.dart';
import 'package:farmlink/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';

class viewCartUI extends StatefulWidget {
  @override
  _viewCartUIState createState() => _viewCartUIState();
}

class _viewCartUIState extends State<viewCartUI> with AutomaticKeepAliveClientMixin {
  final cartController = Get.find<CartController>();
  final ScrollController _scrollController = ScrollController();
  final RxBool isUpdating = false.obs;

  @override
  bool get wantKeepAlive => true;

  Future<void> _refreshCart() async {
    try {
      isUpdating.value = true;
      await cartController.createCart();
    } finally {
      isUpdating.value = false;
    }
  }

  Future<void> _updateQuantity(bool increase, dynamic produce) async {
    try {
      isUpdating.value = true;
      if (increase) {
        await cartController.addProduceToCart(produce);
      } else {
        await cartController.removeOneProduceFromCart(produce);
      }
    } finally {
      isUpdating.value = false;
    }
  }

  Future<void> _removeItem(dynamic produce) async {
    try {
      isUpdating.value = true;
      await cartController.removeProduceFromCart(produce);
    } finally {
      isUpdating.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        title: Text('Shopping Cart'),
      ),
      body: Obx(() {
        if (cartController.cart.value.produces.isEmpty) {
          return _buildEmptyCart();
        }
        return RefreshIndicator(
          onRefresh: _refreshCart,
          child: Column(
            children: [
              Expanded(child: _buildCartList()),
              _buildCartSummary(),
            ],
          ),
        );
      }),
      bottomNavigationBar: bottomNavigationBarCustomer(
        currentRoute: '/viewCart',
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 80,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'Your cart is empty',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Add some products to start shopping',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Get.offAllNamed('/homepageCustomer'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Styles.primaryColor,
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Continue Shopping',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartList() {
    return Obx(() {
      final produces = cartController.cart.value.produces;
      return ListView.separated(
        controller: _scrollController,
        padding: EdgeInsets.all(16),
        itemCount: produces.length,
        separatorBuilder: (context, index) => Divider(height: 32),
        itemBuilder: (context, index) {
          final produce = produces[index];
          final quantity = cartController.cart.value.quantity[produce.pid] ?? 0;
          final itemTotal = produce.price * quantity;

          return Dismissible(
            key: Key('cart_item_${produce.pid}'),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: EdgeInsets.only(right: 20),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.delete_outline,
                color: Colors.white,
                size: 30,
              ),
            ),
            confirmDismiss: (direction) async {
              return await showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Remove Item'),
                    content: Text('Are you sure you want to remove this item from your cart?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: Text(
                          'Remove',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
            onDismissed: (direction) => _removeItem(produce),
            child: Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Hero(
                    tag: 'cart_product_${produce.pid}',
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CachedNetworkImage(
                        imageUrl: produce.imageUrls[0],
                        width: 100,
                        height: 100,
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
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          produce.productName,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'RM${produce.price.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: Styles.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildQuantityControl(produce, quantity),
                            Text(
                              'RM${itemTotal.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }

  Widget _buildQuantityControl(dynamic produce, int quantity) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildQuantityButton(
            icon: Icons.remove,
            onPressed: () => _updateQuantity(false, produce),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              quantity.toString(),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          _buildQuantityButton(
            icon: Icons.add,
            onPressed: () => _updateQuantity(true, produce),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Obx(() => InkWell(
      onTap: isUpdating.value ? null : onPressed,
      child: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 16,
          color: isUpdating.value ? Colors.grey.shade400 : Colors.grey.shade700,
        ),
      ),
    ));
  }

  Widget _buildCartSummary() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, -2),
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
                Text(
                  'Total Amount',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Obx(() => Text(
                  'RM${cartController.calculateTotalPrice().toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Styles.primaryColor,
                  ),
                )),
              ],
            ),
            SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: Obx(() => ElevatedButton(
                onPressed: isUpdating.value || cartController.cart.value.produces.isEmpty
                    ? null
                    : () => Get.toNamed('/checkout'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Styles.primaryColor,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Proceed to Checkout',
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
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}