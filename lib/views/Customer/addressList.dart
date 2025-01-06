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