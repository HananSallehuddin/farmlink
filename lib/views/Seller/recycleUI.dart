import 'package:farmlink/bottomNaviBarSeller.dart';
import 'package:farmlink/controllers/ProductController.dart';
import 'package:farmlink/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class recycleUI extends StatelessWidget {
  final ProductController productController = Get.find<ProductController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Expired Products"),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 4,
      ),
      body: Column(
        children: [
          // Reminder Banner
          Container(
            padding: EdgeInsets.all(16),
            color: Colors.yellow[100],
            child: Row(
              children: [
                Icon(Icons.warning, color: Colors.orange, size: 24),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Reminder: Recycled produces need to be sent to Unit Kompos PascaTuai.",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange[800],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Refreshable Product List
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => productController.refreshProducts(),
              child: Obx(() {
                if (productController.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                final expiredProducts = productController.produceList.where(
                  (product) => product.isExpired() || product.status == 'recycled'
                ).toList();

                if (expiredProducts.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.recycling, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No expired products',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: expiredProducts.length,
                  itemBuilder: (context, index) {
                    final product = expiredProducts[index];
                    final isExpired = product.isExpired();
                    final isRecycled = product.status == 'recycled';

                    return Card(
                      margin: EdgeInsets.only(bottom: 16),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Column(
                          children: [
                            // Status Banner
                            Container(
                              color: isRecycled ? Colors.red : Colors.orange,
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(vertical: 8),
                              child: Text(
                                isRecycled ? 'RECYCLED' : 'EXPIRED',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(16),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Product Image
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: product.imageUrls.isNotEmpty
                                      ? Image.network(
                                          product.imageUrls[0],
                                          width: 100,
                                          height: 100,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) =>
                                            Container(
                                              width: 100,
                                              height: 100,
                                              color: Colors.grey[300],
                                              child: Icon(Icons.error),
                                            ),
                                        )
                                      : Container(
                                          width: 100,
                                          height: 100,
                                          color: Colors.grey[300],
                                          child: Icon(Icons.image),
                                        ),
                                  ),
                                  SizedBox(width: 16),
                                  // Product Details
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          product.productName,
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          'Stock: ${product.stock}',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        Text(
                                          'Expiry: ${DateFormat('dd MMM yyyy').format(product.expiryDate)}',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        SizedBox(height: 8),
                                        if (!isRecycled)
                                          ElevatedButton(
                                            onPressed: () => _showRecycleConfirmation(
                                              context,
                                              product,
                                            ),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.red,
                                              foregroundColor: Colors.white,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                            ),
                                            child: Text('Mark as Recycled'),
                                          ),
                                      ],
                                    ),
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
              }),
            ),
          ),
        ],
      ),
      bottomNavigationBar: bottomNavigationBarSeller(
        currentRoute: '/recyclePage',
      ),
    );
  }

  void _showRecycleConfirmation(BuildContext context, var product) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Recycle'),
          content: Text('Are you sure you want to mark this product as recycled?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                try {
                  product.status = 'recycled';
                  await productController.updateProduce(product);
                  Get.snackbar(
                    'Success',
                    'Product marked as recycled',
                    backgroundColor: Colors.green,
                    colorText: Colors.white,
                  );
                } catch (e) {
                  Get.snackbar(
                    'Error',
                    'Failed to update product status',
                    backgroundColor: Colors.red,
                    colorText: Colors.white,
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text('Confirm'),
            ),
          ],
        );
      },
    );
  }
}
