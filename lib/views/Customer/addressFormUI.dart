// import 'package:farmlink/controllers/UserController.dart';
// import 'package:farmlink/models/UserModel.dart';
// import 'package:farmlink/styles.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// class addressFormUI extends StatefulWidget {
//   @override
//   _addressFormUIState createState() => _addressFormUIState();
// }

// class _addressFormUIState extends State<addressFormUI> {
//   final _formKey = GlobalKey<FormState>();
//   final UserController userController = Get.find<UserController>();
  
//   final TextEditingController _addressController = TextEditingController();
//   final TextEditingController _zipCodeController = TextEditingController();
//   final TextEditingController _cityController = TextEditingController();
//   final TextEditingController _stateController = TextEditingController();
  
//   final RxBool isProcessing = false.obs;
//   final RxBool isEditMode = false.obs;
//   Address? addressToEdit;

//   @override
//   void initState() {
//     super.initState();
//     addressToEdit = Get.arguments as Address?;
//     if (addressToEdit != null) {
//       isEditMode.value = true;
//       _initializeFormWithAddress(addressToEdit!);
//     }
//   }

//   void _initializeFormWithAddress(Address address) {
//     _addressController.text = address.address;
//     _zipCodeController.text = address.zipCode;
//     _cityController.text = address.city;
//     _stateController.text = address.state;
//   }

//   Future<void> _handleSubmit() async {
//     if (_formKey.currentState?.validate() ?? false) {
//       try {
//         isProcessing.value = true;
        
//         final newAddress = Address(
//           address: _addressController.text,
//           zipCode: _zipCodeController.text,
//           city: _cityController.text,
//           state: _stateController.text,
//         );

//         // Validate address format
//         await userController.validateAddressFormat(newAddress);

//         if (isEditMode.value) {
//           await userController.updateAddress(addressToEdit!, newAddress);
//         } else {
//           await userController.addAddress(newAddress);
//         }

//         Get.back();
//         Get.snackbar(
//           'Success',
//           isEditMode.value ? 'Address updated successfully' : 'Address added successfully',
//           backgroundColor: Colors.green,
//           colorText: Colors.white,
//         );
//       } catch (e) {
//         Get.snackbar(
//           'Error',
//           e.toString(),
//           backgroundColor: Colors.red,
//           colorText: Colors.white,
//         );
//       } finally {
//         isProcessing.value = false;
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: () async {
//         return !isProcessing.value;
//       },
//       child: Scaffold(
//         appBar: AppBar(
//           leading: IconButton(
//             icon: Icon(Icons.arrow_back),
//             onPressed: isProcessing.value ? null : () => Get.back(),
//           ),
//           title: Text(isEditMode.value ? "Edit Address" : "Add New Address"),
//           centerTitle: true,
//         ),
//         body: SingleChildScrollView(
//           physics: isProcessing.value
//               ? NeverScrollableScrollPhysics()
//               : AlwaysScrollableScrollPhysics(),
//           padding: const EdgeInsets.all(16),
//           child: Form(
//             key: _formKey,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 _buildTextFormField(
//                   controller: _addressController,
//                   label: 'Street Address',
//                   hint: 'Enter your street address',
//                   icon: Icons.home,
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Please enter your street address';
//                     }
//                     return null;
//                   },
//                 ),
//                 SizedBox(height: 16),
//                 _buildTextFormField(
//                   controller: _zipCodeController,
//                   label: 'Zip Code',
//                   hint: 'Enter zip code',
//                   icon: Icons.local_post_office,
//                   keyboardType: TextInputType.number,
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Please enter zip code';
//                     }
//                     if (!RegExp(r'^\d{5}(-\d{4})?$').hasMatch(value)) {
//                       return 'Please enter a valid zip code';
//                     }
//                     return null;
//                   },
//                 ),
//                 SizedBox(height: 16),
//                 _buildTextFormField(
//                   controller: _cityController,
//                   label: 'City',
//                   hint: 'Enter city',
//                   icon: Icons.location_city,
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Please enter city';
//                     }
//                     return null;
//                   },
//                 ),
//                 SizedBox(height: 16),
//                 _buildTextFormField(
//                   controller: _stateController,
//                   label: 'State',
//                   hint: 'Enter state',
//                   icon: Icons.map,
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Please enter state';
//                     }
//                     return null;
//                   },
//                 ),
//                 SizedBox(height: 24),
//                 Container(
//                   width: double.infinity,
//                   child: Obx(() => ElevatedButton(
//                     onPressed: isProcessing.value ? null : _handleSubmit,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Styles.primaryColor,
//                       padding: EdgeInsets.symmetric(vertical: 16),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                     ),
//                     child: isProcessing.value
//                         ? SizedBox(
//                             width: 24,
//                             height: 24,
//                             child: CircularProgressIndicator(
//                               strokeWidth: 2,
//                               valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                             ),
//                           )
//                         : Text(
//                             isEditMode.value ? 'Update Address' : 'Add Address',
//                             style: TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.white,
//                             ),
//                           ),
//                   )),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildTextFormField({
//     required TextEditingController controller,
//     required String label,
//     required String hint,
//     required IconData icon,
//     required String? Function(String?) validator,
//     TextInputType keyboardType = TextInputType.text,
//   }) {
//     return TextFormField(
//       controller: controller,
//       enabled: !isProcessing.value,
//       decoration: InputDecoration(
//         labelText: label,
//         hintText: hint,
//         prefixIcon: Icon(icon),
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(8),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(8),
//           borderSide: BorderSide(color: Styles.primaryColor, width: 2),
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(8),
//           borderSide: BorderSide(color: Colors.grey.shade400),
//         ),
//         errorBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(8),
//           borderSide: BorderSide(color: Colors.red),
//         ),
//         focusedErrorBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(8),
//           borderSide: BorderSide(color: Colors.red, width: 2),
//         ),
//         filled: true,
//         fillColor: Colors.grey.shade50,
//       ),
//       keyboardType: keyboardType,
//       validator: validator,
//       style: TextStyle(fontSize: 16),
//     );
//   }

//   @override
//   void dispose() {
//     _addressController.dispose();
//     _zipCodeController.dispose();
//     _cityController.dispose();
//     _stateController.dispose();
//     super.dispose();
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';
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
                        DocumentReference newAddressRef = FirebaseFirestore.instance.collection('addresses').doc();
                        Address newAddress = Address( 
                        address: _address!,
                        zipCode: _zipCode!,
                        city: _city!,
                        state: _state!,
                        reference: newAddressRef,
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
      autovalidateMode: AutovalidateMode.onUserInteraction, 

    );
  }
}


