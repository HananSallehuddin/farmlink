import 'package:farmlink/bottomNaviBarSeller.dart';
import 'package:farmlink/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:farmlink/controllers/ProductController.dart';
import 'package:cached_network_image/cached_network_image.dart';

class HomepageSeller extends StatefulWidget {
  @override
  State<HomepageSeller> createState() => _HomepageSellerState();
}

class _HomepageSellerState extends State<HomepageSeller> with AutomaticKeepAliveClientMixin {
  final productController = Get.find<ProductController>();
  final searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final RxBool isSearchActive = false.obs;
  final RxString selectedCategory = 'All'.obs;
  final categories = ['All', 'Vegetables', 'Fruits', 'Herbs', 'Others'];

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await Future.delayed(const Duration(milliseconds: 100));
    productController.refreshProducts();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildCategoryFilter(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => productController.refreshProducts(),
              child: _buildProductGrid(),
            ),
          ),
        ],
      ),
      bottomNavigationBar: bottomNavigationBarSeller(
        currentRoute: '/homepageSeller',
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
  return AppBar(
    leading: Image.asset(
      'assets/farmlink logo wo quotes.png',
      height: 150,
    ),
    title: Center(
      child: Text(
        'Farmlink',
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
    actions: [
      GestureDetector(
        onTap: () => Get.toNamed('/productForm'),
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 8),
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Styles.primaryColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.add, color: Colors.white),
        ),
      ),
    ],
  );
}

    Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: searchController,
        decoration: InputDecoration(
          labelText: 'Search Products',
          hintText: 'Enter product name...',
          prefixIcon: Icon(Icons.search),
          suffixIcon: IconButton(
            icon: Icon(Icons.clear),
            onPressed: () {
              searchController.clear();
              productController.filterProduce('');
            },
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onChanged: (value) {
          productController.filterProduce(value);
        },
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Container(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        padding: EdgeInsets.symmetric(horizontal: 8),
        itemBuilder: (context, index) {
          return Obx(() {
            final category = categories[index];
            final isSelected = selectedCategory.value == category;
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: FilterChip(
                label: Text(category),
                selected: isSelected,
                onSelected: (selected) {
                  selectedCategory.value = category;
                  if (category == 'All') {
                    productController.filterProduce('');
                  } else {
                    productController.filterProduce(category);
                  }
                },
                backgroundColor: Colors.grey.shade200,
                selectedColor: Styles.primaryColor,
                checkmarkColor: Colors.white,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                ),
              ),
            );
          });
        },
      ),
    );
  }

  Widget _buildProductGrid() {
    return Obx(() {
      if (productController.isLoading.value) {
        return Center(child: CircularProgressIndicator());
      }

      if (productController.filteredProduceList.isEmpty) {
        return CustomScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.inventory_2_outlined,
                      size: 64,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No products uploaded yet',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }

      return GridView.builder(
        controller: _scrollController,
        padding: EdgeInsets.all(16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 0.7,
        ),
        itemCount: productController.filteredProduceList.length,
        cacheExtent: 1000,
        itemBuilder: (context, index) {
          final produce = productController.filteredProduceList[index];
          return Hero(
            tag: 'product_${produce.pid}',
            child: Material(
              child: InkWell(
                onLongPress: () => _showDeleteConfirmation(context, productController, produce),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 5,
                  child: Stack(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
                              child: Stack(
                                children: [
                                  if (produce.imageUrls.isNotEmpty)
                                    CachedNetworkImage(
                                      imageUrl: produce.imageUrls[0],
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      placeholder: (context, url) => Container(
                                        color: Colors.grey[300],
                                        child: Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                      ),
                                      errorWidget: (context, url, error) => Container(
                                        color: Colors.grey[300],
                                        child: Icon(Icons.error),
                                      ),
                                      memCacheWidth: 300,
                                      memCacheHeight: 300,
                                    ),
                                  if (produce.status != 'available')
                                    Container(
                                      color: Colors.black54,
                                      child: Center(
                                        child: Text(
                                          produce.status.toUpperCase(),
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  produce.productName,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'RM${produce.price.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 14,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Stock: ${produce.stock}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                                Text(
                                  produce.status,
                                  style: TextStyle(
                                    color: _getStatusColor(produce.status),
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: () {
                            Get.toNamed('/updateProduce', parameters: {'pid': produce.pid});
                          },
                          child: Container(
                            padding: EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Icon(
                              Icons.edit,
                              color: Colors.black,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );
    });
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'available':
        return Colors.green;
      case 'out of stock':
        return Colors.orange;
      case 'recycled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _showDeleteConfirmation(BuildContext context, ProductController productController, var product) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Are you sure you want to delete this product?',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(context);
                      await productController.deleteProductFromListing(product.pid);
                      await productController.refreshProducts();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    child: Text('Delete'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}