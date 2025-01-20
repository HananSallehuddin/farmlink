import 'package:farmlink/controllers/RatingController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:farmlink/controllers/ProductController.dart';
import 'package:farmlink/controllers/CartController.dart';
import 'package:farmlink/styles.dart';
import 'package:farmlink/bottomNaviBarCustomer.dart';
import 'package:cached_network_image/cached_network_image.dart';

class HomepageCustomer extends StatefulWidget {
  @override
  State<HomepageCustomer> createState() => _HomepageCustomerState();
}

class _HomepageCustomerState extends State<HomepageCustomer> with AutomaticKeepAliveClientMixin {
  final ProductController productController = Get.find<ProductController>();
  final CartController cartController = Get.find<CartController>();
  final RatingController ratingController = Get.find<RatingController>();
  final searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final RxString selectedCategory = 'All'.obs;
  final categories = ['All', 'Vegetables', 'Fruits', 'Herbs', 'Others'];

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    // Initial load of products with debounce
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
      bottomNavigationBar: bottomNavigationBarCustomer(
        currentRoute: '/homepageCustomer',
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
        Obx(() {
          final itemCount = cartController.cart.value.quantity.isEmpty
              ? 0
              : cartController.cart.value.quantity.values.fold<int>(0, (prev, qty) => prev + qty);
          return Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.shopping_cart_outlined),
                onPressed: () => Get.toNamed('/viewCart'),
              ),
              if (itemCount > 0)
                Positioned(
                  top: 5,
                  right: 5,
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
        SizedBox(width: 10),
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
        padding: EdgeInsets.symmetric(horizontal: 8.0),
        itemBuilder: (context, index) {
          return Obx(() {
            final category = categories[index];
            final isSelected = selectedCategory.value == category;
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.0),
              child: FilterChip(
                label: Text(category),
                selected: isSelected,
                onSelected: (bool selected) {
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
                    Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'No products available',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
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
          childAspectRatio: 0.65,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: productController.filteredProduceList.length,
        cacheExtent: 1000, // Increase cache for smoother scrolling
        itemBuilder: (context, index) {
          final product = productController.filteredProduceList[index];
          return Hero(
            tag: 'product_${product.pid}',
            child: Material(
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  if (product.pid != null) {
                    //Get.toNamed('/viewProduce', parameters: {'pid': product.pid});
                    Get.toNamed('/viewProduce', parameters: {'pid': product.pid.toString()});
                  }
                },
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              if (product.imageUrls.isNotEmpty)
                                CachedNetworkImage(
                                  imageUrl: product.imageUrls[0],
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Container(
                                    color: Colors.grey[200],
                                    child: Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) => Icon(Icons.error),
                                  memCacheWidth: 300,
                                  memCacheHeight: 300,
                                ),
                              if (product.status != 'available')
                                Container(
                                  color: Colors.black54,
                                  child: Center(
                                    child: Text(
                                      product.status.toUpperCase(),
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
                        padding: EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.productName,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 4),
                            Text(
                              'RM${product.price.toStringAsFixed(2)}',
                              style: TextStyle(
                                color: Styles.primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Stock: ${product.stock}',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                                if (product.status == 'available')
                                  Material(
                                    color: Colors.transparent,
                                    child: IconButton(
                                      icon: Icon(Icons.add_shopping_cart),
                                      onPressed: () {
                                        cartController.addProduceToCart(product);
                                      },
                                      color: Styles.primaryColor,
                                      iconSize: 20,
                                      padding: EdgeInsets.zero,
                                      constraints: BoxConstraints(),
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
              ),
            ),
          );
        },
      );
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}