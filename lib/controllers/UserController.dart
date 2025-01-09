import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farmlink/controllers/CartController.dart';
import 'package:farmlink/controllers/LoginController.dart';
import 'package:farmlink/models/Cart.dart';
import 'package:farmlink/models/UserModel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class UserController extends GetxController {
  var uid = ''.obs;
  late String currentUID;

  // Reactive list for storing addresses
  var addresses = <Address>[].obs;
  //for single optional address
  var selectedAddress = Rxn<Address>();

  @override
  void onInit() {
    super.onInit();
    initializeCurrentUID();
  }

  void initializeCurrentUID(){
    var user = FirebaseAuth.instance.currentUser;
    if(user!=null){
      currentUID = user.uid;
      fetchAddresses();
    } else {
      print('No user is currently logged in');
    }
  }

  void selectAddress(Address address) {
  selectedAddress.value = address;
  print('Selected Address updated: ${selectedAddress.value}');  // Debugging line
}

  Future<void> addAddress(Address newAddress) async {
  currentUID = FirebaseAuth.instance.currentUser!.uid;
  try {
    if (currentUID.isEmpty) {
      throw Exception("User UID is empty. Cannot update Firestore.");
    }

    DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(currentUID).get();
    
    if (userDoc.exists) {
      // Get existing addresses or set an empty list if not found
      List<dynamic> addressList = userDoc['addresses'] ?? [];

      // Add new address to the list (reference can be null)
      addressList.add(newAddress.toJson());

      // Update the addresses in Firestore
      await FirebaseFirestore.instance.collection('users').doc(currentUID).update({
        'addresses': addressList,
      });
      addresses.add(newAddress);

      // After adding, refresh the local list of addresses
      print("Address added successfully.");
    } else {
      throw Exception("User document not found in Firestore.");
    }
  } catch (e) {
    print('Error adding address: $e');
  }
}

  // Fetch addresses from Firestore (optional, if you want to load them initially)
  Future<void> fetchAddresses() async {
  try {
    // Fetch user document from Firestore
    DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(currentUID).get();
    print(currentUID);
    
    if (userDoc.exists) {
      // Get data from the document
      var data = userDoc.data() as Map<String, dynamic>?;

      if (data != null && data.containsKey('addresses')) {
        // Retrieve the addresses field and map to Address objects
        List<dynamic> addressList = data['addresses'] ?? [];
        
        // Map each address to an Address object
        addresses.value = addressList.map((address) {
          return Address.fromJson(address);
        }).toList();

        // Optionally select the first address if available
        if (addresses.isNotEmpty) {
          selectedAddress.value = addresses.first;
          print('First address reference: ${selectedAddress.value?.reference}');
        }
      } else {
        print('No "addresses" field found in the user document');
      }
    } else {
      print('User document does not exist');
    }
  } catch (e) {
    print('Error fetching addresses: $e');
  }
}

   Future<void> deleteAddress(Address addressToDelete) async {
  try {
    // Get the latest user document
    DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(currentUID).get();
    List<dynamic> addressList = userDoc['addresses'] ?? [];
    // Remove the address by comparing string fields
    addressList.removeWhere((address) {
      var addr = Address.fromJson(address);
      return addr.address == addressToDelete.address &&
             addr.city == addressToDelete.city &&
             addr.state == addressToDelete.state &&
             addr.zipCode == addressToDelete.zipCode;
    });
    // Update Firestore with the new address list
    await FirebaseFirestore.instance.collection('users').doc(currentUID).update({
      'addresses': addressList,
    });
    // Fetch the updated addresses
    fetchAddresses();
  } catch (e) {
    print('Error deleting address: $e');
  }
}

Future<void> logout() async {
  try {
    // Step 1: Clear user data by calling the method in LoginController
    await Get.find<LoginController>().clearUserData(); // Correct method reference
    
    // Step 2: Clear cart data
    await Get.find<CartController>().clearCart();
    
    // Step 3: Sign out from Firebase Auth
    await FirebaseAuth.instance.signOut();

    // Step 4: Redirect to the login screen (or any screen as required)
    Get.offAllNamed('/login');
  } catch (e) {
    print("Logout error: $e");
    Get.snackbar('Error', 'Failed to log out');
  }
}

}