// import 'package:farmlink/controllers/UserController.dart';
// import 'package:farmlink/controllers/CartController.dart';
// import 'package:farmlink/models/UserModel.dart';
// import 'package:farmlink/styles.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// class addressListUI extends StatefulWidget {
//   @override
//   _addressListUIState createState() => _addressListUIState();
// }

// class _addressListUIState extends State<addressListUI> with AutomaticKeepAliveClientMixin {
//   final UserController userController = Get.find<UserController>();
//   final CartController cartController = Get.find<CartController>();
//   final RxBool isProcessing = false.obs;

//   @override
//   bool get wantKeepAlive => true;

//   @override
//   void initState() {
//     super.initState();
//     _refreshAddresses();
//   }

//   Future<void> _refreshAddresses() async {
//     try {
//       isProcessing.value = true;
//       await userController.fetchAddresses();
//     } finally {
//       isProcessing.value = false;
//     }
//   }

//   Future<void> _handleAddressSelection(Address address) async {
//     try {
//       isProcessing.value = true;
      
//       // Update user controller
//       userController.selectAddress(address);
      
//       // Update cart with full address
//       final fullAddress = '${address.address}, ${address.city}, ${address.state} ${address.zipCode}';
//       await cartController.updateCartAddress(fullAddress);
      
//       Get.back();
//     } catch (e) {
//       print('Error selecting address: $e');
//       Get.snackbar(
//         'Error',
//         'Failed to update shipping address',
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//       );
//     } finally {
//       isProcessing.value = false;
//     }
//   }

//   Future<void> _handleAddressDelete(Address address) async {
//     try {
//       isProcessing.value = true;
//       await userController.deleteAddress(address);
//       await _refreshAddresses();
//     } finally {
//       isProcessing.value = false;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     super.build(context);

//     return Scaffold(
//       appBar: AppBar(
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back),
//           onPressed: isProcessing.value ? null : () => Get.back(),
//         ),
//         title: Text("Addresses"),
//         centerTitle: true,
//       ),
//       floatingActionButton: FloatingActionButton(
//         backgroundColor: Styles.primaryColor,
//         onPressed: isProcessing.value ? null : () => Get.toNamed('addressForm'),
//         elevation: 3,
//         child: Icon(Icons.add, color: Colors.white),
//       ),
//       body: RefreshIndicator(
//         onRefresh: _refreshAddresses,
//         child: Obx(() {
//           if (userController.isLoading.value) {
//             return Center(child: CircularProgressIndicator());
//           }

//           final addresses = userController.addresses;
//           if (addresses.isEmpty) {
//             return _buildEmptyState();
//           }

//           return ListView.builder(
//             padding: const EdgeInsets.all(16),
//             itemCount: addresses.length,
//             itemBuilder: (context, index) {
//               final address = addresses[index];
//               final isSelected = address == userController.selectedAddress.value;
//               return _buildAddressCard(address, isSelected);
//             },
//           );
//         }),
//       ),
//     );
//   }

//   Widget _buildEmptyState() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(
//             Icons.location_off,
//             size: 64,
//             color: Colors.grey,
//           ),
//           SizedBox(height: 16),
//           Text(
//             'No addresses saved yet',
//             style: TextStyle(
//               fontSize: 18,
//               color: Colors.grey,
//             ),
//           ),
//           SizedBox(height: 24),
//           ElevatedButton(
//             onPressed: isProcessing.value ? null : () => Get.toNamed('addressForm'),
//             style: Styles.primaryButtonStyle,
//             child: Text('Add new address'),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildAddressCard(Address address, bool isSelected) {
//     return Dismissible(
//       key: Key(address.address + address.zipCode),
//       direction: DismissDirection.endToStart,
//       confirmDismiss: (direction) async {
//         return await showDialog(
//           context: context,
//           builder: (BuildContext context) {
//             return AlertDialog(
//               title: Text('Delete Address'),
//               content: Text('Are you sure you want to delete this address?'),
//               actions: [
//                 TextButton(
//                   onPressed: () => Navigator.of(context).pop(false),
//                   child: Text('Cancel'),
//                 ),
//                 TextButton(
//                   onPressed: () => Navigator.of(context).pop(true),
//                   child: Text(
//                     'Delete',
//                     style: TextStyle(color: Colors.red),
//                   ),
//                 ),
//               ],
//             );
//           },
//         );
//       },
//       onDismissed: (direction) => _handleAddressDelete(address),
//       background: Container(
//         alignment: Alignment.centerRight,
//         color: Colors.red,
//         padding: EdgeInsets.only(right: 16),
//         child: Icon(Icons.delete, color: Colors.white),
//       ),
//       child: Card(
//         elevation: 4,
//         margin: const EdgeInsets.symmetric(vertical: 8),
//         color: isSelected ? Styles.primaryColor.withOpacity(0.1) : null,
//         child: ListTile(
//           contentPadding: EdgeInsets.all(16),
//           title: Text(
//             address.address,
//             style: TextStyle(
//               fontWeight: FontWeight.bold,
//               fontSize: 16,
//             ),
//           ),
//           subtitle: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               SizedBox(height: 8),
//               Text(
//                 '${address.city}, ${address.state}',
//                 style: TextStyle(fontSize: 14),
//               ),
//               Text(
//                 address.zipCode,
//                 style: TextStyle(fontSize: 14),
//               ),
//             ],
//           ),
//           trailing: Row(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               if (isSelected)
//                 Icon(Icons.check_circle, color: Styles.primaryColor),
//               IconButton(
//                 icon: Icon(Icons.edit),
//                 onPressed: isProcessing.value
//                     ? null
//                     : () => Get.toNamed('addressForm', arguments: address),
//               ),
//             ],
//           ),
//           onTap: isProcessing.value ? null : () => _handleAddressSelection(address),
//         ),
//       ),
//     );
//   }
// }

import 'package:farmlink/controllers/UserController.dart';
import 'package:farmlink/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class addressListUI extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final userController = Get.find<UserController>();
    userController.fetchAddresses();

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Styles.primaryColor,
        onPressed: () => Get.toNamed('addressForm'),
        elevation: 3,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        title: const Text("Addresses"),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 4,
      ),
      body: Obx(() {
        var addresses = userController.addresses;
        var selectedAddress = userController.selectedAddress.value;

        if (addresses.isEmpty) {
          return Center(
            child: ElevatedButton(
              onPressed: () => Get.toNamed('addressForm'),
              child: const Text('Add new address'),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: addresses.length,
          itemBuilder: (context, index) {
            var address = addresses[index];
            bool isSelected = address == selectedAddress;
            return Dismissible(
              key: Key(address.address),
              direction: DismissDirection.startToEnd,
              background: Container(
                alignment: Alignment.centerLeft,
                color: Colors.red,
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              onDismissed: (direction) {
                userController.deleteAddress(address);
                //Get.snackbar('Deleted', 'Address removed successfully.');
              },
              child: Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 8),
                color: isSelected ? Styles.primaryColor : null,
                child: ListTile(
                  title: Text(
                    address.address,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${address.city}, ${address.state}'),
                      Text(address.zipCode),
                    ],
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle, color: Colors.black26) // Show checkmark only for selected address
                      : null,
                  onTap: () {
                    userController.selectAddress(address);
                  },
                ),
              ),
            );
          },
        );
      }),
    );
  }
}