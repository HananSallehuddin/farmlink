import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farmlink/bottomNaviBarCustomer.dart';
import 'package:farmlink/controllers/CartController.dart';
import 'package:farmlink/controllers/ChatController.dart';
import 'package:farmlink/controllers/ProductController.dart';
import 'package:farmlink/controllers/LoginController.dart';
import 'package:farmlink/controllers/RatingController.dart';
import 'package:farmlink/models/LocalProduce.dart';
import 'package:farmlink/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';

class viewProduceUI extends StatefulWidget {
  @override
  State<viewProduceUI> createState() => _viewProduceUIState();
}

class _viewProduceUIState extends State<viewProduceUI> with SingleTickerProviderStateMixin {
  final ProductController productController = Get.find<ProductController>();
  final CartController cartController = Get.find<CartController>();
  final ChatController chatController = Get.find<ChatController>();
  final RatingController ratingController = Get.find<RatingController>();
  final LoginController loginController = Get.find<LoginController>();
  final String? pid = Get.parameters['pid'];
  final RxInt currentImageIndex = 0.obs;
  late PageController _pageController;
  final RxBool isLoading = true.obs;
  final Rx<LocalProduce?> produce = Rx<LocalProduce?>(null);
  final RxString currentRole = ''.obs;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      if (pid == null) return;
      
      // Load user role
      String? role = await loginController.getUserRole();
      currentRole.value = role ?? '';

      // Load product with real-time updates
      await _loadProduct();

      ratingController.fetchProduceRatingForViewPage(pid!);
      
      // Set up real-time listener for product updates
      _setupProductListener();
    } catch (e) {
      print('Error initializing data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadProduct() async {
    try {
      if (pid == null) return;
      LocalProduce loadedProduce = await productController.viewProduceDetails(pid!);
      produce.value = loadedProduce;
    } catch (e) {
      print('Error loading product: $e');
    }
  }


  void _setupProductListener() {
    if (pid == null) return;
    // Set up real-time listener for product updates
    productController.listenToProductChanges(pid!, (updatedProduce) {
      produce.value = updatedProduce;
    });
  }

  Future<void> _showRestockDialog(BuildContext context, LocalProduce produce) async {
    final TextEditingController stockController = TextEditingController();
    
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Restock Product'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Current Batch: ${produce.currentBatch}'),
              SizedBox(height: 16),
              TextFormField(
                controller: stockController,
                decoration: InputDecoration(
                  labelText: 'New Stock Amount',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (stockController.text.isNotEmpty) {
                  int newStock = int.parse(stockController.text);
                  produce.stockBatches.add({
                    'batch': produce.currentBatch + 1,
                    'stock': newStock,
                    'date': DateTime.now(),
                  });
                  produce.currentBatch += 1;
                  produce.stock += newStock;
                  produce.status = 'available';
                  
                  await productController.updateProduce(produce);
                  Navigator.pop(context);
                }
              },
              child: Text('Restock'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        actions: [
          Obx(() {
            final itemCount = cartController.cart.value.quantity.isEmpty
                ? 0
                : cartController.cart.value.quantity.values.fold<int>(0, (prev, qty) => prev + qty);
            return Stack(
              children: [
                IconButton(
                  icon: Icon(Icons.shopping_cart_outlined),
                  onPressed: () => Get.toNamed('/viewCart'),
                ),
                if (itemCount > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        itemCount.toString(),
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            );
          }),
          SizedBox(width: 16),
        ],
      ),
      body: Obx(() {
        if (isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        final currentProduce = produce.value;
        if (currentProduce == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48, color: Colors.red),
                SizedBox(height: 16),
                Text(
                  'Product not found.\nPlease try again.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.red),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _loadProduct,
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildImageCarousel(currentProduce),
                _buildProductDetails(currentProduce, context),
              ],
            ),
          ),
        );
      }),
      bottomNavigationBar: currentRole.value == 'Seller'
          ? null
          : bottomNavigationBarCustomer(currentRoute: '/viewProduce'),
    );
  }

  Widget _buildImageCarousel(LocalProduce produce) {
    return Stack(
      children: [
        Container(
          height: 300,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) => currentImageIndex.value = index,
            itemCount: produce.imageUrls.length,
            itemBuilder: (context, index) {
              return Hero(
                tag: 'product_${produce.pid}_$index',
                child: CachedNetworkImage(
                  imageUrl: produce.imageUrls[index],
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
              );
            },
          ),
        ),
        if (produce.status != 'available')
          Container(
            height: 300,
            color: Colors.black54,
            child: Center(
              child: Text(
                produce.status.toUpperCase(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        if (produce.imageUrls.length > 1)
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                produce.imageUrls.length,
                (index) => Obx(() {
                  return Container(
                    width: 8,
                    height: 8,
                    margin: EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: currentImageIndex.value == index
                          ? Styles.primaryColor
                          : Colors.grey.withOpacity(0.5),
                    ),
                  );
                }),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildProductDetails(LocalProduce produce, BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  produce.productName,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              
              GestureDetector(
              onTap: () {
                Get.toNamed('/ratingList', parameters: {'pid': produce.pid.toString()});
              },
            child: Row(
              children: [
                Obx(() {
                  return Text(
                    ratingController.averageRating.value == 0.0
                        ? 'Not rated yet'  // Display if rating is 0.0
                        : '${ratingController.averageRating.value.toStringAsFixed(1)}',  // Display the average rating otherwise
                    style: TextStyle(fontSize: 16),
                  );
                }),
                SizedBox(width: 4),
                // Show star icon only if there is a rating (not 0.0)
                if (ratingController.averageRating.value > 0.0)
                  Icon(Icons.star, color: Colors.amber, size: 20),
                SizedBox(width: 4),
                Icon(
                  Icons.arrow_forward,
                  size: 16,
                  color: Colors.black,
                ),
                
              ],
            ),
            ),
          ],
        ),
        if (currentRole.value == 'Seller') ...[
          SizedBox(height: 16),
          Text(
            'Batch Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text('Current Batch: ${produce.currentBatch}'),
          if (produce.stockBatches.isNotEmpty) ...[
            SizedBox(height: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: produce.stockBatches.map((batch) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    'Batch ${batch['batch']}: ${batch['stock']} units added on ${DateFormat('dd MMM yyyy').format(batch['date'].toDate())}',
                    style: TextStyle(fontSize: 14),
                  ),
                );
              }).toList(),
            ),
          ],
          SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: Icon(Icons.add_shopping_cart),
              label: Text('Restock Product'),
              onPressed: () => _showRestockDialog(context, produce),
              style: ElevatedButton.styleFrom(
                backgroundColor: Styles.primaryColor,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
        SizedBox(height: 8),
          Text(
            'RM${produce.price.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 20,
              color: Styles.primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          _buildInfoCard('Stock', '${produce.stock} units'),
          SizedBox(height: 16),
          _buildStatusChip(produce.status),
          SizedBox(height: 16),
          Text(
            'Description',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(produce.description),
          SizedBox(height: 16),
          Text(
            'Product Details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          _buildInfoRow('Category', produce.category ?? 'Not specified'),
          _buildInfoRow('Weight', '${produce.weight ?? "N/A"} ${produce.unit}'),
          _buildInfoRow(
            'Expiry Date',
            DateFormat('dd MMM yyyy').format(produce.expiryDate),
          ),
          FutureBuilder<Map<String, dynamic>>(
                              future: _getSellerInfo(produce.userRef!),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                       _buildInfoRow('Seller:', snapshot.data!['name']),
                                    ],
                                  );
                                }
                                return SizedBox();
                              },
                            ),
          SizedBox(height: 24),
          
          if (currentRole.value == 'Customer') ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: produce.status == 'available'
                    ? () => cartController.addProduceToCart(produce)
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Styles.primaryColor,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: Icon(Icons.shopping_cart, color: Colors.white),
                label: Text(
                  produce.status == 'available'
                      ? 'Add to Cart'
                      : produce.status.capitalizeFirst!,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  if (produce.userRef != null) {
                    String sellerId = produce.userRef!.id;
                    chatController.createChatRoom(
                      sellerId,
                      '',
                      productId: produce.pid,
                      productName: produce.productName,
                    );
                  }
                },
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: Styles.primaryColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: Icon(Icons.chat_bubble_outline, color: Styles.primaryColor),
                label: Text(
                  'Contact Seller',
                  style: TextStyle(
                    fontSize: 16,
                    color: Styles.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color chipColor;
    switch (status.toLowerCase()) {
      case 'available':
        chipColor = Colors.green;
        break;
      case 'out of stock':
        chipColor = Colors.red;
        break;
      case 'recycled':
        chipColor = Colors.orange;
        break;
      default:
        chipColor = Colors.grey;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: chipColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.capitalizeFirst!,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildInfoCard(String label, String value) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: int.parse(value.split(' ')[0]) > 0 ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<Map<String, dynamic>> _getSellerInfo(DocumentReference userRef) async {
    try {
      final userDoc = await userRef.get();
      if (!userDoc.exists) {
        return {'name': 'Unknown Seller', 'rating': 0.0};
      }

      final userData = userDoc.data() as Map<String, dynamic>;
      
      // Get seller's ratings
      final ratingsSnapshot = await FirebaseFirestore.instance
          .collection('ratings')
          .where('sellerRef', isEqualTo: userRef)
          .get();

      double averageRating = 0.0;
      if (ratingsSnapshot.docs.isNotEmpty) {
        double totalRating = ratingsSnapshot.docs
            .map((doc) => doc['score'] as num)
            .fold(0, (sum, score) => sum + score);
        averageRating = totalRating / ratingsSnapshot.docs.length;
      }

      return {
        'name': userData['username'] ?? 'Unknown Seller',
        'rating': averageRating,
      };
    } catch (e) {
      print('Error getting seller info: $e');
      return {'name': 'Unknown Seller', 'rating': 0.0};
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}