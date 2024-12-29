import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farmlink/models/LocalProduce.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class ProductController extends GetxController {
  //var produceList = <LocalProduce>[].obs;
  var filteredProduceList = <LocalProduce>[].obs;
  var productName = ''.obs;
  var description = ''.obs;
  var price = 0.0.obs;
  var stock = 0.obs;
  var expiryDate = Rx<DateTime?>(null);
  late String currentUserID;  
  var imageUrls = <String>[].obs; // List to hold multiple image URLs

  // Called when controller is initialized
  @override
  void onInit() {
    super.onInit();
    //retrieve current user id
    currentUserID = FirebaseAuth.instance.currentUser!.uid; 
    //filteredProduceList.value = produceList;
  }

  Future<void> addProductToListing() async {
  try {
    // Upload images
    List<String> uploadedImageUrls = await uploadAllImages();
    if (uploadedImageUrls.isEmpty) {
      Get.snackbar('Error', 'No images were uploaded');
      return;
    }

    // Use the correct collection for storing the product
    final productRef = FirebaseFirestore.instance.collection('localProduce').doc(); // This creates a doc in the 'localProduce' collection
    final productId = productRef.id;  // Get the generated doc ID

    // Create new product object
    LocalProduce newProduce = LocalProduce(
      pid: productId, // Set the pid to the document ID
      productName: productName.value,
      price: price.value,
      description: description.value,
      imageUrls: uploadedImageUrls,
      stock: stock.value,
      expiryDate: expiryDate.value!,
      userRef: FirebaseFirestore.instance.collection('users').doc(currentUserID),
    );

    // Add the product to Firestore
    await productRef.set(newProduce.toJson()); // Save the product to the localProduce collection

    //produceList.add(newProduce); // Add to local list
    filteredProduceList.add(newProduce);
    Get.snackbar('Success', 'Product added successfully');
    imageUrls.clear();
    Get.back();
  } catch (e) {
    Get.snackbar('Error', 'Failed to add product: $e');
  }
}


  Future<void> deleteProductFromListing(String pid) async {
  try {
    // Assuming product is already selected, directly find it in the list
    LocalProduce deletedProduct = filteredProduceList.firstWhere((produce) => produce.pid == pid);

    // If found, delete the product from Firestore
    DocumentReference productRef = FirebaseFirestore.instance.collection('localProduce').doc(deletedProduct.pid);
    await productRef.delete();

    // Remove from the local list
    //produceList.remove(deletedProduct);
    filteredProduceList.remove(deletedProduct);

    Get.snackbar('Success', 'Product deleted successfully');
  } catch (e) {
    Get.snackbar('Error', 'Failed to delete product: $e');
  }
}

  // Pick multiple images
  Future<void> pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFiles = await picker.pickMultiImage(); // Use pickMultiImage for multiple selections

      if (pickedFiles != null && pickedFiles.length <= 5) {
        for (var pickedFile in pickedFiles) {
          if (File(pickedFile.path).existsSync()){
            imageUrls.add(pickedFile.path);
          } else {
            Get.snackbar('Error', 'Selected file does not exist');
          }// Add each picked image to the list
        }
      } else {
        Get.snackbar('Error', 'Please select up to 5 images');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to pick images: $e');
    }
  }

  // Upload image to Firebase Storage and get the URL
  Future<String> uploadImageToStorage(String filePath) async {
  try {
    if (!File(filePath).existsSync()) {
      throw Exception('File does not exist at path: $filePath');
    }

    final fileName = DateTime.now().toIso8601String();
    final ref = FirebaseStorage.instance.ref().child('localProduceImages/$fileName');
    final uploadTask = await ref.putFile(File(filePath));

    // Ensure the upload task is complete
    if (uploadTask.state == TaskState.success) {
      return await ref.getDownloadURL();
    } else {
      throw Exception('Upload failed.');
    }
  } catch (e) {
    Get.snackbar('Error', 'Failed to upload image: $e');
    rethrow;
  }
}

Future<List<String>> uploadAllImages() async {
  try {
    List<String> uploadedUrls = [];
    for (var filePath in imageUrls) {
      String downloadUrl = await uploadImageToStorage(filePath);
      uploadedUrls.add(downloadUrl);
    }
    return uploadedUrls;
  } catch (e) {
    Get.snackbar('Error', 'Failed to upload all images: $e');
    return [];
  }
}
void filterProduce(String query) {
  if(query.isEmpty){
    filteredProduceList.refresh();
  } else{
    filteredProduceList.value = filteredProduceList.where((produce) => 
          produce.productName.toLowerCase().contains(query.toLowerCase())).toList();
  }
}
}