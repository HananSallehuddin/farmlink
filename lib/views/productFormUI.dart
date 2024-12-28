import 'dart:io';

import 'package:farmlink/controllers/ProductController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class productFormUI extends StatelessWidget {
  final productController = Get.find<ProductController>();
  final _formKey = GlobalKey<FormState>();

  // Define TextEditingControllers for each field
  final productNameController = TextEditingController();
  final descriptionController = TextEditingController();
  final priceController = TextEditingController();
  final stockController = TextEditingController();
  final expiryDateController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Get.toNamed('homepageSeller');
          },
        ),
        title: Text("Add your local produce"),
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
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // Product name field
              _buildTextFormField(
                controller: productNameController,
                labelText: 'Local Produce Name',
                hintText: 'Enter local produce name',
                onSaved: (value) => productController.productName.value = value!,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Please enter your local produce name' : null,
              ),
              SizedBox(height: 16),

              // Description field
              _buildTextFormField(
                controller: descriptionController,
                labelText: 'Description',
                hintText: 'Enter description for your local produce',
                onSaved: (value) => productController.description.value = value!,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Please enter a description for your local produce' : null,
              ),
              SizedBox(height: 16),

              // Price field
              _buildTextFormField(
                controller: priceController,
                labelText: 'Price',
                hintText: 'Enter local produce price per kilogram',
                onSaved: (value) =>
                    productController.price.value = double.tryParse(value!) ?? 0.0,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Please enter your local produce price per kg' : null,
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 16),

              // Stock field
              _buildTextFormField(
                controller: stockController,
                labelText: 'Stock',
                hintText: 'Enter available stock for your local produce',
                onSaved: (value) =>
                    productController.stock.value = int.tryParse(value!) ?? 0,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Please enter available stock for your local produce' : null,
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 16),

              // Expiry date field
              GestureDetector(
                onTap: () async {
                  DateTime? selectedDate = await showDatePicker(
                    context: context,
                    initialDate: productController.expiryDate.value ?? DateTime.now(),
                    firstDate: DateTime(1900),
                    lastDate: DateTime(2100),
                  );

                  if (selectedDate != null) {
                    // Format the selected date to a string in yyyy-MM-dd format
                    productController.expiryDate.value = selectedDate;
                    expiryDateController.text = selectedDate.toLocal().toString().split(' ')[0]; // yyyy-MM-dd format
                  }
                },
                child: AbsorbPointer(
                  child: _buildTextFormField(
                    controller: expiryDateController,
                    labelText: 'Expiry Date',
                    hintText: 'Enter expiration date for your local produce',
                    onSaved: (value) => productController.expiryDate.value = DateTime.tryParse(value!),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Please enter expiration date for your local produce' : null,
                  ),
                ),
              ),
              SizedBox(height: 16),

              // Picture selection slot
              GetX<ProductController>(
                builder: (controller) {
                  return Column(
                    children: [
                      // Display selected image(s)
                      controller.imageUrls.isNotEmpty
                          ? Column(
                              children: controller.imageUrls
                                  .map(
                                    (imagePath) => Image.file(
                                      File(imagePath),
                                      height: 100,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                  .toList(),
                            )
                          : Text('No images selected'),
                      SizedBox(height: 16),

                      // Buttons for picking an image
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {
                              productController.pickImage(ImageSource.camera);
                            },
                            icon: Icon(Icons.camera),
                            label: Text('Camera'),
                          ),
                          ElevatedButton.icon(
                            onPressed: () {
                              productController.pickImage(ImageSource.gallery);
                            },
                            icon: Icon(Icons.photo_library),
                            label: Text('Gallery'),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),

              // Submit button
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    productController.addProductToListing().then((_) {
                      //Get.back(); // Navigate back after saving
                    });
                  }
                },
                child: Text('Add local produce'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Move the _buildTextFormField method inside the ProductFormUI class
  Widget _buildTextFormField({
    required TextEditingController controller,
    required String labelText,
    required String hintText,
    required FormFieldSetter<String> onSaved,
    required String? Function(String?) validator,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50.0),
          borderSide: BorderSide(color: Colors.green, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50.0),
          borderSide: BorderSide(color: Colors.grey, width: 1),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 20),
      ),
      keyboardType: keyboardType,
      validator: validator,
      onSaved: onSaved,
      autovalidateMode: AutovalidateMode.onUserInteraction, // This makes validation happen when user interacts with the field

    );
  }
}