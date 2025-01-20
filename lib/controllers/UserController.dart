import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farmlink/models/UserModel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class UserController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  late String currentUID;
  var currentUser = Rxn<UserModel>();
  var addresses = <Address>[].obs;
  var selectedAddress = Rxn<Address>();
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    initializeCurrentUID();
    _setupUserListener();
    fetchAddresses();
  }

  void _setupUserListener() {
    _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        currentUID = user.uid;
        _loadUserData();
        fetchAddresses();
      } else {
        currentUser.value = null;
        addresses.clear();
        selectedAddress.value = null;
      }
    });
  }

  void initializeCurrentUID() {
    var user = _auth.currentUser;
    if (user != null) {
      currentUID = user.uid;
      _loadUserData();
      fetchAddresses();
    }
  }

  Future<void> _loadUserData() async {
    try {
      isLoading.value = true;
      DocumentSnapshot doc = await _firestore.collection('users').doc(currentUID).get();
      
      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        currentUser.value = UserModel.fromJson(data);
      }
    } catch (e) {
      print('Error loading user data: $e');
      errorMessage.value = 'Failed to load user data';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateUserProfile({
    String? username,
    String? email,
    String? phoneNumber,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      Map<String, dynamic> updateData = {};
      if (username != null) updateData['username'] = username;
      if (email != null) updateData['email'] = email;
      if (phoneNumber != null) updateData['phoneNumber'] = phoneNumber;

      await _firestore.collection('users').doc(currentUID).update(updateData);
      await _loadUserData();
      
      Get.snackbar('Success', 'Profile updated successfully');
    } catch (e) {
      print('Error updating profile: $e');
      errorMessage.value = 'Failed to update profile';
    } finally {
      isLoading.value = false;
    }
  }

  void selectAddress(Address address) {
    selectedAddress.value = address;
  }

  // Future<void> addAddress(Address newAddress) async {
  //   try {
  //     isLoading.value = true;
  //     errorMessage.value = '';

  //     if (currentUID.isEmpty) {
  //       throw Exception('User ID is empty. Cannot update Firestore.');
  //     }

  //     DocumentSnapshot userDoc = await _firestore.collection('users').doc(currentUID).get();
      
  //     if (userDoc.exists) {
  //       List<dynamic> addressList = (userDoc.data() as Map<String, dynamic>)['addresses'] ?? [];
  //       addressList.add(newAddress.toJson());

  //       await _firestore.collection('users').doc(currentUID).update({
  //         'addresses': addressList,
  //       });

  //       addresses.add(newAddress);
  //       if (addresses.length == 1) {
  //         selectedAddress.value = newAddress;
  //       }

  //       Get.snackbar('Success', 'Address added successfully');
  //     } else {
  //       throw Exception('User document not found in Firestore.');
  //     }
  //   } catch (e) {
  //     print('Error adding address: $e');
  //     errorMessage.value = 'Failed to add address';
  //   } finally {
  //     isLoading.value = false;
  //   }
  // }

  Future<void> addAddress(Address newAddress) async {
    try {
      isLoading.value = true;
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String currentUID = user.uid;

        DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(currentUID).get();
        if (userDoc.exists) {
          List<dynamic> addressList = userDoc['addresses'] ?? [];
          addressList.add(newAddress.toJson());

          await FirebaseFirestore.instance.collection('users').doc(currentUID).update({
            'addresses': addressList,
          });
          addresses.add(newAddress);

          print("Address added successfully.");
        } else {
          throw Exception("User document not found in Firestore.");
        }
      }
    } catch (e) {
      print('Error adding address: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateAddress(Address oldAddress, Address newAddress) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      DocumentSnapshot userDoc = await _firestore.collection('users').doc(currentUID).get();
      
      if (userDoc.exists) {
        List<dynamic> addressList = (userDoc.data() as Map<String, dynamic>)['addresses'] ?? [];
        
        int index = addressList.indexWhere((addr) {
          Map<String, dynamic> address = addr as Map<String, dynamic>;
          return address['address'] == oldAddress.address &&
                 address['city'] == oldAddress.city &&
                 address['state'] == oldAddress.state &&
                 address['zipCode'] == oldAddress.zipCode;
        });

        if (index != -1) {
          addressList[index] = newAddress.toJson();
          
          await _firestore.collection('users').doc(currentUID).update({
            'addresses': addressList,
          });

          await fetchAddresses();
          
          if (selectedAddress.value == oldAddress) {
            selectedAddress.value = newAddress;
          }

          Get.snackbar('Success', 'Address updated successfully');
        }
      }
    } catch (e) {
      print('Error updating address: $e');
      errorMessage.value = 'Failed to update address';
    } finally {
      isLoading.value = false;
    }
  }

  // Future<void> deleteAddress(Address addressToDelete) async {
  //   try {
  //     isLoading.value = true;
  //     errorMessage.value = '';

  //     DocumentSnapshot userDoc = await _firestore.collection('users').doc(currentUID).get();
  //     List<dynamic> addressList = (userDoc.data() as Map<String, dynamic>)['addresses'] ?? [];

  //     addressList.removeWhere((address) {
  //       Map<String, dynamic> addr = address as Map<String, dynamic>;
  //       return addr['address'] == addressToDelete.address &&
  //              addr['city'] == addressToDelete.city &&
  //              addr['state'] == addressToDelete.state &&
  //              addr['zipCode'] == addressToDelete.zipCode;
  //     });

  //     await _firestore.collection('users').doc(currentUID).update({
  //       'addresses': addressList,
  //     });

  //     addresses.removeWhere((addr) => 
  //       addr.address == addressToDelete.address &&
  //       addr.city == addressToDelete.city &&
  //       addr.state == addressToDelete.state &&
  //       addr.zipCode == addressToDelete.zipCode
  //     );

  //     if (selectedAddress.value == addressToDelete) {
  //       selectedAddress.value = addresses.isNotEmpty ? addresses.first : null;
  //     }

  //     Get.snackbar('Success', 'Address deleted successfully');
  //   } catch (e) {
  //     print('Error deleting address: $e');
  //     errorMessage.value = 'Failed to delete address';
  //   } finally {
  //     isLoading.value = false;
  //   }
  // }

  Future<void> deleteAddress(Address addressToDelete) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String currentUID = user.uid;

        DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(currentUID).get();
        List<dynamic> addressList = userDoc['addresses'] ?? [];
        
        addressList.removeWhere((address) {
          var addr = Address.fromJson(address);
          return addr.address == addressToDelete.address &&
                 addr.city == addressToDelete.city &&
                 addr.state == addressToDelete.state &&
                 addr.zipCode == addressToDelete.zipCode;
        });

        await FirebaseFirestore.instance.collection('users').doc(currentUID).update({
          'addresses': addressList,
        });

        fetchAddresses();
      }
    } catch (e) {
      print('Error deleting address: $e');
    }
  }

  // Future<void> fetchAddresses() async {
  //   try {
  //     isLoading.value = true;
  //     errorMessage.value = '';

  //     DocumentSnapshot userDoc = await _firestore.collection('users').doc(currentUID).get();
      
  //     if (userDoc.exists) {
  //       Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
  //       List<dynamic> addressList = userData['addresses'] ?? [];
        
  //       addresses.value = addressList
  //           .map((address) => Address.fromJson(address as Map<String, dynamic>))
  //           .toList();

  //       if (addresses.isNotEmpty && selectedAddress.value == null) {
  //         selectedAddress.value = addresses.first;
  //       }
  //     }
  //   } catch (e) {
  //     print('Error fetching addresses: $e');
  //     errorMessage.value = 'Failed to fetch addresses';
  //   } finally {
  //     isLoading.value = false;
  //   }
  // }

  Future<void> fetchAddresses() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String currentUID = user.uid;

        DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(currentUID).get();
        if (userDoc.exists) {
          var data = userDoc.data() as Map<String, dynamic>?;
          if (data != null && data.containsKey('addresses')) {
            List<dynamic> addressList = data['addresses'] ?? [];
            addresses.value = addressList.map((address) {
              return Address.fromJson(address);
            }).toList();

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
      }
    } catch (e) {
      print('Error fetching addresses: $e');
    }
  }
  

  Future<void> setDefaultAddress(Address address) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Move the selected address to the front of the list
      addresses.remove(address);
      addresses.insert(0, address);
      selectedAddress.value = address;

      // Update the order in Firestore
      List<Map<String, dynamic>> addressList = addresses.map((addr) => addr.toJson()).toList();
      await _firestore.collection('users').doc(currentUID).update({
        'addresses': addressList,
      });

      Get.snackbar('Success', 'Default address updated');
    } catch (e) {
      print('Error setting default address: $e');
      errorMessage.value = 'Failed to set default address';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> validateAddressFormat(Address address) async {
    if (address.address.isEmpty ||
        address.city.isEmpty ||
        address.state.isEmpty ||
        address.zipCode.isEmpty) {
      throw Exception('All address fields are required');
    }

    // Simple zipcode validation (can be enhanced based on country format)
    if (!RegExp(r'^\d{5}(-\d{4})?$').hasMatch(address.zipCode)) {
      throw Exception('Invalid zipcode format');
    }
  }

  // Clear user data on logout
  void clearUserData() {
    currentUser.value = null;
    addresses.clear();
    selectedAddress.value = null;
    errorMessage.value = '';
  }

  @override
  void onClose() {
    clearUserData();
    super.onClose();
  }
}