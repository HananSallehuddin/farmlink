import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farmlink/controllers/LoginController.dart';
import 'package:farmlink/models/LocalProduce.dart';
import 'package:farmlink/services/NotificationService.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class ProductController extends GetxController {
  var produceList = <LocalProduce>[].obs;
  var filteredProduceList = <LocalProduce>[].obs;
  var recycledProduceList = <LocalProduce>[].obs;
  var isLoading = false.obs;

  // Form fields
  var productName = ''.obs;
  var description = ''.obs;
  var price = 0.0.obs;
  var stock = 0.obs;
  var category = ''.obs;
  var weight = 0.0.obs;
  var unit = 'kg'.obs;
  var expiryDate = Rx<DateTime?>(null);
  var imageUrls = <String>[].obs;
  var status = 'available'.obs;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final LoginController loginController = Get.find<LoginController>();
  final NotificationService notificationService = Get.find<NotificationService>();

  @override
  void onInit() {
    super.onInit();
    ever(produceList, (_) {
      filteredProduceList.assignAll(produceList);
    });

    _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        refreshProducts();
        fetchRecycledProduce();
      } else {
        produceList.clear();
        filteredProduceList.clear();
        recycledProduceList.clear();
      }
    });
  }

  void _clearFormData() {
    productName.value = '';
    description.value = '';
    price.value = 0.0;
    stock.value = 0;
    category.value = '';
    weight.value = 0.0;
    unit.value = 'kg';
    expiryDate.value = null;
    imageUrls.clear();
  }

  Future<void> addProductToListing() async {
    try {
      isLoading.value = true;
      User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('No user logged in');
      }

      List<String> uploadedImageUrls = await uploadAllImages();
      if (uploadedImageUrls.isEmpty) {
        Get.snackbar('Error', 'Please select at least one image');
        return;
      }

      final produceRef = _firestore.collection('localProduce').doc();
      final pid = produceRef.id;

      LocalProduce newProduce = LocalProduce(
        pid: pid,
        productName: productName.value,
        price: price.value,
        description: description.value,
        imageUrls: uploadedImageUrls,
        stock: stock.value,
        expiryDate: expiryDate.value!,
        status: 'available',
        userRef: _firestore.collection('users').doc(currentUser.uid),
        category: category.value,
        weight: weight.value,
        unit: unit.value,
      );

      await produceRef.set(newProduce.toJson());
      produceList.insert(0, newProduce);
      filteredProduceList.insert(0, newProduce);
      _clearFormData();
      await refreshProducts();
      Get.back();
      Get.snackbar('Success', 'Product added successfully');
    } catch (e) {
      print('Error adding product: $e');
      Get.snackbar('Error', 'Failed to add product: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshProducts() async {
    try {
      isLoading.value = true;
      User? currentUser = _auth.currentUser;
      if (currentUser == null) return;

      String? role = await loginController.getUserRole();
      if (role == null) return;

      Query<Map<String, dynamic>> query = _firestore.collection('localProduce');
      if (role == 'Seller') {
        final userRef = _firestore.collection('users').doc(currentUser.uid);
        query = query.where('userRef', isEqualTo: userRef);
      } else if (role == 'Customer') {
        query = query.where('status', isEqualTo: 'available');
      }

      final QuerySnapshot<Map<String, dynamic>> querySnapshot = await query.get();
      final List<LocalProduce> produces = [];

      for (var doc in querySnapshot.docs) {
        Map<String, dynamic> data = doc.data();
        data['pid'] = doc.id;
        try {
          LocalProduce produce = LocalProduce.fromJson(data);
          produce.checkAndUpdateStatus();
          produces.add(produce);

          // If stock becomes 0, trigger notification for seller
          if (produce.stock == 0 && role == 'Seller') {
            // Stock notification will be handled by NotificationService listener
            await _firestore.collection('localProduce')
                .doc(produce.pid)
                .update({'status': 'out of stock'});
          }

          // Update status in Firestore if changed
          if (produce.status != data['status']) {
            await _firestore.collection('localProduce')
                .doc(produce.pid)
                .update({'status': produce.status});
          }
        } catch (e) {
          print('Error processing product ${doc.id}: $e');
          continue;
        }
      }

      produceList.assignAll(produces);
      filteredProduceList.assignAll(produces);
    } catch (e) {
      print('Error in refreshProducts: $e');
      Get.snackbar(
        'Error',
        'Failed to load products',
        backgroundColor: Color(0xFFD32F2F),
        colorText: Color(0xFFFFFFFF),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchRecycledProduce() async {
    try {
      isLoading.value = true;
      User? currentUser = _auth.currentUser;
      if (currentUser == null) return;

      final userRef = _firestore.collection('users').doc(currentUser.uid);
      final QuerySnapshot<Map<String, dynamic>> querySnapshot = await _firestore
          .collection('localProduce')
          .where('status', isEqualTo: 'recycled')
          .where('userRef', isEqualTo: userRef)
          .get();

      final List<LocalProduce> recycledProduces = [];
      for (var doc in querySnapshot.docs) {
        Map<String, dynamic> data = doc.data();
        data['pid'] = doc.id;
        try {
          recycledProduces.add(LocalProduce.fromJson(data));
        } catch (e) {
          print('Error processing recycled product ${doc.id}: $e');
          continue;
        }
      }

      recycledProduceList.assignAll(recycledProduces);
    } catch (e) {
      print('Error in fetchRecycledProduce: $e');
      Get.snackbar('Error', 'Failed to load recycled products');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteProductFromListing(String pid) async {
    try {
      isLoading.value = true;
      LocalProduce deletedProduct = produceList.firstWhere((produce) =>
      produce.pid == pid);

      // Delete images from storage
      for (String imageUrl in deletedProduct.imageUrls) {
        try {
          await _storage.refFromURL(imageUrl).delete();
        } catch (e) {
          print('Error deleting image: $e');
        }
      }

      await _firestore.collection('localProduce').doc(pid).delete();
      produceList.removeWhere((produce) => produce.pid == pid);
      filteredProduceList.removeWhere((produce) => produce.pid == pid);
      Get.snackbar('Success', 'Product deleted successfully');
    } catch (e) {
      print('Error deleting product: $e');
      Get.snackbar('Error', 'Failed to delete product');
    } finally {
      isLoading.value = false;
    }
  }


  Future<void> updateProduce(LocalProduce updatedProduce) async {
    try {
      isLoading.value = true;
      if (updatedProduce.pid.isEmpty) {
        throw Exception('Invalid product ID');
      }

      // Get current produce data to check for stock changes
      DocumentSnapshot currentDoc = await _firestore
          .collection('localProduce')
          .doc(updatedProduce.pid)
          .get();

      if (currentDoc.exists) {
        Map<String, dynamic> currentData = currentDoc.data() as Map<String, dynamic>;
        int currentStock = currentData['stock'] as int;

        // If stock is becoming 0, notification will be triggered by listener
        if (currentStock > 0 && updatedProduce.stock == 0) {
          updatedProduce.status = 'out of stock';
        }
      }

      await _firestore.collection('localProduce')
          .doc(updatedProduce.pid)
          .update(updatedProduce.toJson());

      int index = produceList.indexWhere((p) => p.pid == updatedProduce.pid);
      if (index != -1) {
        produceList[index] = updatedProduce;
      }

      await refreshProducts();
      Get.back();
      Get.snackbar('Success', 'Product updated successfully');
    } catch (e) {
      print('Error updating product: $e');
      Get.snackbar('Error', 'Failed to update product');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> changeStatusToRecycledDone(String productId) async {
  try {
    isLoading.value = true;

    // Find the product in the local list
    int index = produceList.indexWhere((p) => p.pid == productId);
    if (index != -1 && produceList[index].status == 'recycled') {
      // Update the status to 'recycledDone'
      produceList[index].status = 'recycledDone';

      // Update Firestore to reflect the change
      final productDoc = _firestore.collection('localProduce').doc(productId);
      await productDoc.update({'status': 'recycledDone'});

      // Confirm the update by checking the document in Firestore again
      final updatedDoc = await productDoc.get();
      if (updatedDoc.exists) {
        print('Firestore updated: ${updatedDoc.data()}');
      } else {
        print('Document not found in Firestore.');
      }

      // Refresh the produce list locally to reflect the status change
      produceList.refresh();
      filteredProduceList.refresh();
      recycledProduceList.refresh();
      
      // Provide feedback to the user
      Get.snackbar('Success', 'Product marked as recycled done');
    } else {
      Get.snackbar('Error', 'Product is not in recycled status or not found');
    }
  } catch (e) {
    print('Error changing status: $e');
    Get.snackbar('Error', 'Failed to change product status');
  } finally {
    isLoading.value = false;
  }
}

  Future<LocalProduce> viewProduceDetails(String pid) async {
    try {
      final doc = await _firestore.collection('localProduce').doc(pid).get();
      if (!doc.exists) {
        throw Exception('Product not found');
      }

      Map<String, dynamic> data = doc.data()!;
      data['pid'] = doc.id;
      LocalProduce produce = LocalProduce.fromJson(data);
      produce.checkAndUpdateStatus();

      if (produce.status != data['status']) {
        await _firestore.collection('localProduce')
            .doc(pid)
            .update({'status': produce.status});
      }

      return produce;
    } catch (e) {
      print('Error loading product details: $e');
      throw Exception('Failed to load product details');
    }
  }

  void listenToProductChanges(String pid, Function(LocalProduce) onUpdate) {
    _firestore
        .collection('localProduce')
        .doc(pid)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        data['pid'] = snapshot.id;
        LocalProduce updatedProduce = LocalProduce.fromJson(data);
        updatedProduce.checkAndUpdateStatus();
        onUpdate(updatedProduce);
      }
    }, onError: (error) {
      print('Error listening to product changes: $error');
    });
  }

  Future<void> pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFiles = await picker.pickMultiImage();
      if (pickedFiles != null && pickedFiles.length <= 5) {
        imageUrls.clear();
        for (var pickedFile in pickedFiles) {
          if (File(pickedFile.path).existsSync()) {
            imageUrls.add(pickedFile.path);
          }
        }
      } else if (pickedFiles != null && pickedFiles.length > 5) {
        Get.snackbar('Error', 'Please select up to 5 images');
      }
    } catch (e) {
      print('Error picking images: $e');
      Get.snackbar('Error', 'Failed to pick images');
    }
  }

  Future<String> uploadImageToStorage(String filePath) async {
    try {
      final file = File(filePath);
      if (!file.existsSync()) {
        throw Exception('File does not exist');
      }

      final String fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
      final ref = _storage.ref().child('localProduceImages').child(fileName);

      final metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {'picked-file-path': filePath}
      );

      final TaskSnapshot snapshot = await ref.putFile(file, metadata);
      if (snapshot.state == TaskState.success) {
        final downloadUrl = await snapshot.ref.getDownloadURL();
        return downloadUrl;
      } else {
        throw Exception('Upload failed with state: ${snapshot.state}');
      }
    } catch (e) {
      print('Error uploading image: $e');
      rethrow;
    }
  }

  Future<List<String>> uploadAllImages() async {
    if (imageUrls.isEmpty) return [];
    try {
      List<String> uploadedUrls = [];
      for (var filePath in imageUrls) {
        String downloadUrl = await uploadImageToStorage(filePath);
        uploadedUrls.add(downloadUrl);
      }
      return uploadedUrls;
    } catch (e) {
      print('Error uploading images: $e');
      return [];
    }
  }

  void filterProduce(String query) {
    if (query.isEmpty) {
      filteredProduceList.assignAll(produceList);
    } else {
      filteredProduceList.value = produceList.where((produce) {
        bool matchesName = produce.productName.toLowerCase().contains(query.toLowerCase());
        bool matchesCategory = produce.category?.toLowerCase() == query.toLowerCase();
        return matchesName || matchesCategory;
      }).toList();
    }
  }

  void filterByCategory(String category) {
    if (category == 'All') {
      filteredProduceList.assignAll(produceList);
    } else {
      filteredProduceList.value = produceList.where((produce) =>
        produce.category?.toLowerCase() == category.toLowerCase()
      ).toList();
    }
  }

  Future<String> fetchSellerName(DocumentReference userRef) async {
    try {
      var userDoc = await userRef.get();
      if (userDoc.exists) {
        return userDoc['username'] ?? 'Seller Not Found';
      } else {
        return 'Seller Not Found';
      }
    } catch (e) {
      return 'Error fetching seller';
    }
  }

  @override
  void onClose() {
    imageUrls.clear();
    produceList.clear();
    filteredProduceList.clear();
    recycledProduceList.clear();
    super.onClose();
  }
}