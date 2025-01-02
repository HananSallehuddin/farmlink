import 'package:farmlink/controllers/ProductController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class updateProduceUI extends StatelessWidget {
  final productController = Get.find<ProductController>();
  final _formKey = GlobalKey<FormState>();
  final String pid = Get.parameters['pid'] ?? ''; // Get the product ID passed from previous screen

  updateProduceUI({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Find the produce in the list based on the pid
    final produce = productController.produceList.firstWhere(
      (p) => p.pid == pid, 
    );

    if (produce == null) {
      return Scaffold(
        body: Center(child: Text('Produce not found')),
      );
    }

    // Populate the controller with the produce data
    productController.productName.value = produce.productName;
    productController.description.value = produce.description;
    productController.price.value = produce.price;
    productController.stock.value = produce.stock;
    productController.expiryDate.value = produce.expiryDate;
    productController.status.value = produce.status;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Get.toNamed('homepageSeller');
          },
        ),
        title: Text("Update your local produce"),
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
            children: [
              // Product name field
              _buildTextFormField(
                labelText: 'Local Produce Name',
                hintText: 'Enter local produce name',
                initialValue: produce.productName,
                onSaved: (value) => productController.productName.value = value!,
                validator: (value) => value == null || value.isEmpty ? 'Please enter your local produce name' : null,
              ),
              SizedBox(height: 16),

              // Description field
              _buildTextFormField(
                labelText: 'Description',
                hintText: 'Enter description for your local produce',
                initialValue: produce.description,
                onSaved: (value) => productController.description.value = value!,
                validator: (value) => value == null || value.isEmpty ? 'Please enter a description for your local produce' : null,
              ),
              SizedBox(height: 16),

              // Price field
              _buildTextFormField(
                labelText: 'Price',
                hintText: 'Enter local produce price per kilogram',
                initialValue: produce.price.toString(),
                onSaved: (value) => productController.price.value = double.tryParse(value!) ?? 0.0,
                validator: (value) => value == null || value.isEmpty ? 'Please enter your local produce price per kg' : null,
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 16),

              // Stock field
              _buildTextFormField(
                labelText: 'Stock',
                hintText: 'Enter available stock for your local produce',
                initialValue: produce.stock.toString(),
                onSaved: (value) => productController.stock.value = int.tryParse(value!) ?? 0,
                validator: (value) => value == null || value.isEmpty ? 'Please enter available stock for your local produce' : null,
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 16),

              // Expiry date field
              _buildTextFormField(
                labelText: 'Expiry Date',
                hintText: 'Enter expiration date for your local produce',
                initialValue: produce.expiryDate?.toLocal().toString().split(' ')[0] ?? '',
                onSaved: (value) => productController.expiryDate.value = DateTime.tryParse(value!),
                validator: (value) => value == null || value.isEmpty ? 'Please enter expiration date for your local produce' : null,
              ),
              SizedBox(height: 16),

              // Submit button
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    productController.updateProduce(pid); // Call the controller to update the product
                  }
                },
                child: Text('Update local produce'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required String labelText,
    required String hintText,
    required String initialValue,
    required FormFieldSetter<String> onSaved,
    required String? Function(String?) validator,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      initialValue: initialValue,
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
      autovalidateMode: AutovalidateMode.onUserInteraction,
    );
  }
}