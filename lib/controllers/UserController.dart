import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farmlink/models/UserModel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class UserController extends GetxController {
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
  }

  // void deselectAddress(){
  //   selectedAddress.value = null;
  // }

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

        // Add new address to the list
        addressList.add(newAddress.toJson());

        // Update the addresses in Firestore
        await FirebaseFirestore.instance.collection('users').doc(currentUID).update({
          'addresses': addressList,
        });
        addresses.add(newAddress);

        // After adding, refresh the local list of addresses
        //addresses.value = addressList.map((address) => Address.fromJson(address)).toList();
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
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(currentUID).get();
      if (userDoc.exists) {
        // Map Firestore data to Address objects
        List<dynamic> addressList = userDoc['addresses'] ?? [];
        addresses.value = addressList.map((address) => Address.fromJson(address)).toList();
        if(addresses.isNotEmpty){
          selectedAddress.value = addresses.first;
        }
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
}