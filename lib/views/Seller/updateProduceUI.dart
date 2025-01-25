import 'package:farmlink/controllers/ProductController.dart';
import 'package:farmlink/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class updateProduceUI extends StatelessWidget {
  final productController = Get.find<ProductController>();
  final _formKey = GlobalKey<FormState>();
  final String pid = Get.parameters['pid'] ?? '';

  // Form controllers
  final TextEditingController productNameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController stockController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController expiryDateController = TextEditingController();
  
  // Category and Unit selections
  final RxString selectedCategory = 'Vegetables'.obs;
  final RxString selectedUnit = 'kg'.obs;

  @override
  Widget build(BuildContext context) {
    final categories = ['Vegetables', 'Fruits', 'Herbs', 'Others'];
    final units = ['kg', 'g', 'piece', 'bundle'];

    // Find the produce in the list based on the pid
    final produce = productController.produceList.firstWhere(
      (p) => p.pid == pid,
      orElse: () => throw Exception('Product not found'),
    );

    // Populate the controllers with existing data
    productNameController.text = produce.productName;
    descriptionController.text = produce.description;
    priceController.text = produce.price.toString();
    stockController.text = produce.stock.toString();
    weightController.text = produce.weight?.toString() ?? '';
    expiryDateController.text = DateFormat('yyyy-MM-dd').format(produce.expiryDate);
    selectedCategory.value = produce.category ?? categories[0];
    selectedUnit.value = produce.unit ?? units[0];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        title: Text("Update Product"),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 4,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Current Images Display
              Container(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: produce.imageUrls.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Stack(
                        children: [
                          Image.network(
                            produce.imageUrls[index],
                            height: 100,
                            width: 100,
                            fit: BoxFit.cover,
                          ),
                          Positioned(
                            top: 0,
                            right: 0,
                            child: IconButton(
                              icon: Icon(Icons.close, color: Colors.red),
                              onPressed: () {
                                // Remove image functionality
                                List<String> updatedUrls = List.from(produce.imageUrls);
                                updatedUrls.removeAt(index);
                                produce.imageUrls = updatedUrls;
                                productController.refreshProducts();
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 16),

              // Product Name
              TextFormField(
                controller: productNameController,
                decoration: _buildInputDecoration('Product Name', Icons.shopping_basket),
                validator: (value) => value?.isEmpty ?? true ? 'Please enter product name' : null,
              ),
              SizedBox(height: 16),

              // Category Dropdown
              Obx(() => DropdownButtonFormField<String>(
                value: selectedCategory.value,
                decoration: _buildInputDecoration('Category', Icons.category),
                items: categories.map((String category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    selectedCategory.value = newValue;
                  }
                },
              )),
              SizedBox(height: 16),

              // Description
              TextFormField(
                controller: descriptionController,
                decoration: _buildInputDecoration('Description', Icons.description),
                maxLines: 3,
                validator: (value) => value?.isEmpty ?? true ? 'Please enter description' : null,
              ),
              SizedBox(height: 16),

              // Price
              TextFormField(
                controller: priceController,
                decoration: _buildInputDecoration('Price (RM)', Icons.attach_money),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Please enter price';
                  if (double.tryParse(value!) == null) return 'Please enter valid price';
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Stock
              TextFormField(
                controller: stockController,
                decoration: _buildInputDecoration('Stock', Icons.inventory),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Please enter stock';
                  if (int.tryParse(value!) == null) return 'Please enter valid stock number';
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Weight and Unit
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: weightController,
                      decoration: _buildInputDecoration('Weight', Icons.scale),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value?.isEmpty ?? true) return 'Please enter weight';
                        if (double.tryParse(value!) == null) return 'Please enter valid weight';
                        return null;
                      },
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Obx(() => DropdownButtonFormField<String>(
                      value: selectedUnit.value,
                      decoration: _buildInputDecoration('Unit', null),
                      items: units.map((String unit) {
                        return DropdownMenuItem(
                          value: unit,
                          child: Text(unit),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          selectedUnit.value = newValue;
                        }
                      },
                    )),
                  ),
                ],
              ),
              SizedBox(height: 16),

              // Expiry Date
              TextFormField(
                controller: expiryDateController,
                decoration: _buildInputDecoration('Expiry Date', Icons.calendar_today),
                readOnly: true,
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: produce.expiryDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    expiryDateController.text = DateFormat('yyyy-MM-dd').format(picked);
                  }
                },
                validator: (value) => value?.isEmpty ?? true ? 'Please select expiry date' : null,
              ),
              SizedBox(height: 24),

              // Update Button
              SizedBox(
                width: double.infinity,
                child: Obx(() => ElevatedButton(
                  onPressed: productController.isLoading.value
                      ? null
                      : () async {
                          if (_formKey.currentState!.validate()) {
                            try {
                              final updatedProduce = produce.copyWith(
                                productName: productNameController.text,
                                description: descriptionController.text,
                                price: double.parse(priceController.text),
                                stock: int.parse(stockController.text),
                                category: selectedCategory.value,
                                weight: double.parse(weightController.text),
                                unit: selectedUnit.value,
                                expiryDate: DateFormat('yyyy-MM-dd').parse(expiryDateController.text),
                              );

                              await productController.updateProduce(updatedProduce);
                              //Get.back();

                            } catch (e) {
                              Get.snackbar(
                                'Error',
                                'Failed to update product: ${e.toString()}',
                                backgroundColor: Colors.red,
                                colorText: Colors.white,
                              );
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Styles.primaryColor,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: productController.isLoading.value
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text(
                          'Update Product',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                )),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String label, IconData? icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: icon != null ? Icon(icon) : null,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade400),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Styles.primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.red, width: 2),
      ),
      filled: true,
      fillColor: Colors.grey.shade50,
    );
  }
}