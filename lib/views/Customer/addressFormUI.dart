import 'package:farmlink/controllers/UserController.dart';
import 'package:farmlink/models/UserModel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class addressFormUI extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final userController = Get.find<UserController>();
  String? _address;
  String? _zipCode;
  String? _city;
  String? _state;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Get.back();
          },
        ),
        title: Text("Add new address"),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 4,
      ),
      body: SingleChildScrollView(  
        padding: const EdgeInsets.all(16),
        child: Form(  
          key: _formKey,
          child: Column(  
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _buildTextFormField(
                labelText: 'Address', 
                hintText: 'Enter address', 
                onSaved: (value) => _address = value,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Please enter address' : null,
                ),
                SizedBox(height: 16),
              _buildTextFormField(
                labelText: 'Zipcode', 
                hintText: 'Enter zipcode', 
                onSaved: (value) => _zipCode = value, 
                validator: (value) =>
                    value == null || value.isEmpty ? 'Please enter zipcode' : null,
                ),
                SizedBox(height: 16),
              _buildTextFormField(
                labelText: 'City', 
                hintText: 'Enter city', 
                onSaved: (value) => _city = value, 
                validator: (value) =>
                    value == null || value.isEmpty ? 'Please enter city' : null,
                ),
                SizedBox(height: 16),
              _buildTextFormField(
                labelText: 'State', 
                hintText: 'Enter state', 
                onSaved: (value) => _state = value, 
                validator: (value) =>
                    value == null || value.isEmpty ? 'Please enter city' : null,
                ),
                SizedBox(height: 16),
                ElevatedButton(  
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      
                      try { 
                        Address newAddress = Address( 
                        address: _address!,
                        zipCode: _zipCode!,
                        city: _city!,
                        state: _state!,
                      );
                      await userController.addAddress(newAddress);
                      Get.back();
                      } catch (e) {
                        print('Error adding address: $e');
                      }
                    
                    } 
                  },
                  child: Text('Save address'),
                ),
            ],
          )
        )
      )
    );
  }
  Widget _buildTextFormField({
    required String labelText,
    required String hintText,
    required FormFieldSetter<String> onSaved,
    required String? Function(String?) validator,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
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


