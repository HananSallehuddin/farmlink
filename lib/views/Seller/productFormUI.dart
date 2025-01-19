import 'dart:io';
import 'package:farmlink/controllers/ProductController.dart';
import 'package:farmlink/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class productFormUI extends StatelessWidget {
  final productController = Get.find<ProductController>();
  final _formKey = GlobalKey<FormState>();
  final productNameController = TextEditingController();
  final descriptionController = TextEditingController();
  final priceController = TextEditingController();
  final stockController = TextEditingController();
  final weightController = TextEditingController();
  final expiryDateController = TextEditingController();
  final RxString selectedCategory = 'Vegetables'.obs;
  final RxString selectedUnit = 'kg'.obs;
  final RxList<XFile> selectedImages = <XFile>[].obs;
  final ImagePicker _picker = ImagePicker();

  productFormUI({super.key});

  Future<void> pickImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage();
      if (images.isNotEmpty) {
        if (images.length > 5) {
          Get.snackbar(
            'Error',
            'Maximum 5 images allowed',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          selectedImages.value = images.sublist(0, 5);
        } else {
          selectedImages.value = images;
        }
      }
    } catch (e) {
      print('Error picking images: $e');
      Get.snackbar(
        'Error',
        'Failed to pick images',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> takePhoto() async {
    try {
      final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
      if (photo != null) {
        if (selectedImages.length < 5) {
          selectedImages.add(photo);
        } else {
          Get.snackbar(
            'Error',
            'Maximum 5 images allowed',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      }
    } catch (e) {
      print('Error taking photo: $e');
      Get.snackbar(
        'Error',
        'Failed to take photo',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = ['Vegetables', 'Fruits', 'Herbs', 'Others'];
    final units = ['kg', 'g', 'piece', 'bundle'];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        title: const Text("Add Local Produce"),
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
              // Images Section
              Obx(() => Column(
                children: [
                  if (selectedImages.isNotEmpty)
                    Container(
                      height: 120,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: selectedImages.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Stack(
                              children: [
                                Image.file(
                                  File(selectedImages[index].path),
                                  height: 100,
                                  width: 100,
                                  fit: BoxFit.cover,
                                ),
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: IconButton(
                                    icon: const Icon(Icons.close, color: Colors.red),
                                    onPressed: () {
                                      selectedImages.removeAt(index);
                                    },
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton.icon(
                        onPressed: takePhoto,
                        icon: const Icon(Icons.camera_alt),
                        label: const Text('Camera'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Styles.primaryColor,
                          foregroundColor: Colors.white,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: pickImages,
                        icon: const Icon(Icons.photo_library),
                        label: const Text('Gallery'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Styles.primaryColor,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              )),
              const SizedBox(height: 24),

              // Rest of the form fields...
              TextFormField(
                controller: productNameController,
                decoration: _inputDecoration(
                  label: 'Product Name',
                  hint: 'Enter product name',
                  icon: Icons.shopping_basket,
                ),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Please enter product name' : null,
              ),
              const SizedBox(height: 16),

              // Category Dropdown
              Obx(() => DropdownButtonFormField<String>(
                value: selectedCategory.value,
                decoration: _inputDecoration(
                  label: 'Category',
                  hint: 'Select category',
                  icon: Icons.category,
                ),
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
              const SizedBox(height: 16),

              TextFormField(
                controller: descriptionController,
                decoration: _inputDecoration(
                  label: 'Description',
                  hint: 'Enter product description',
                  icon: Icons.description,
                ),
                maxLines: 3,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Please enter description' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: priceController,
                decoration: _inputDecoration(
                  label: 'Price (RM)',
                  hint: 'Enter price',
                  icon: Icons.attach_money,
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Please enter price';
                  if (double.tryParse(value!) == null)
                    return 'Please enter valid price';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: stockController,
                decoration: _inputDecoration(
                  label: 'Stock',
                  hint: 'Enter available stock',
                  icon: Icons.inventory,
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Please enter stock';
                  if (int.tryParse(value!) == null)
                    return 'Please enter valid stock number';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: weightController,
                      decoration: _inputDecoration(
                        label: 'Weight',
                        hint: 'Enter weight',
                        icon: Icons.scale,
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value?.isEmpty ?? true) return 'Please enter weight';
                        if (double.tryParse(value!) == null)
                          return 'Please enter valid weight';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Obx(() => DropdownButtonFormField<String>(
                      value: selectedUnit.value,
                      decoration: _inputDecoration(
                        label: 'Unit',
                        hint: 'Unit',
                      ),
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
              const SizedBox(height: 16),

              TextFormField(
                controller: expiryDateController,
                decoration: _inputDecoration(
                  label: 'Expiry Date',
                  hint: 'Select expiry date',
                  icon: Icons.calendar_today,
                ),
                readOnly: true,
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    expiryDateController.text =
                        picked.toString().split(' ')[0];
                  }
                },
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Please select expiry date' : null,
              ),
              const SizedBox(height: 24),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: Obx(() => ElevatedButton(
                  onPressed: productController.isLoading.value
                      ? null
                      : () async {
                          if (_formKey.currentState!.validate()) {
                            if (selectedImages.isEmpty) {
                              Get.snackbar(
                                'Error',
                                'Please add at least one image',
                                backgroundColor: Colors.red,
                                colorText: Colors.white,
                              );
                              return;
                            }

                            // Convert XFile paths to strings
                            List<String> imagePaths = selectedImages
                                .map((xFile) => xFile.path)
                                .toList();
                            productController.imageUrls.value = imagePaths;

                            // Save form data
                            productController.productName.value =
                                productNameController.text;
                            productController.description.value =
                                descriptionController.text;
                            productController.price.value =
                                double.parse(priceController.text);
                            productController.stock.value =
                                int.parse(stockController.text);
                            productController.weight.value =
                                double.parse(weightController.text);
                            productController.category.value =
                                selectedCategory.value;
                            productController.unit.value = selectedUnit.value;
                            productController.expiryDate.value =
                                DateTime.parse(expiryDateController.text);

                            await productController.addProductToListing();
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Styles.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: productController.isLoading.value
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Add Product',
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

  InputDecoration _inputDecoration({
    required String label,
    required String hint,
    IconData? icon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: icon != null ? Icon(icon) : null,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Styles.primaryColor, width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade400),
      ),
      filled: true,
      fillColor: Colors.grey.shade50,
    );
  }
}