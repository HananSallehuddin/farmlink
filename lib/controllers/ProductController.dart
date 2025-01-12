import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farmlink/controllers/LoginController.dart';
import 'package:farmlink/models/LocalProduce.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class ProductController extends GetxController {
  //variable to hold value from local produce class
  var produceList = <LocalProduce>[].obs;
  var filteredProduceList = <LocalProduce>[].obs;
  var recycledProduceList = <LocalProduce>[].obs;
  var productName = ''.obs;
  var description = ''.obs;
  var price = 0.0.obs;
  var stock = 0.obs;
  var expiryDate = Rx<DateTime?>(null);
  late String currentUserID;  
  var imageUrls = <String>[].obs; 
  var status = 'available'.obs;
  String userRole = '';
  
  @override
void onInit() {
  super.onInit();

  FirebaseAuth.instance.authStateChanges().listen((user) {
    if (user != null) {
      currentUserID = user.uid;
      print('Current User ID: $currentUserID');
      fetchProduce();
      fetchRecycledProduce();
    } else {
      print('No user signed in');
      Get.snackbar('Notice', 'Please sign in to view your products');
    }
  });
}

  Future<void> addProductToListing() async {
  try {
  
    List<String> uploadedImageUrls = await uploadAllImages();
    if (uploadedImageUrls.isEmpty) {
      Get.snackbar('Error', 'No images were uploaded');
      return;
    }

    final produceRef = FirebaseFirestore.instance.collection('localProduce').doc(); 
    final pid = produceRef.id;  

    // Create new product object
    LocalProduce newProduce = LocalProduce(
      pid: pid, 
      productName: productName.value,
      price: price.value,
      description: description.value,
      imageUrls: uploadedImageUrls,
      stock: stock.value,
      expiryDate: expiryDate.value!,
      status: status.value,
      userRef: FirebaseFirestore.instance.collection('users').doc(currentUserID),
    );

    // Add the product to Firestore
    await produceRef.set(newProduce.toJson()); 

    produceList.add(newProduce); 
    filterProduce('');
    await fetchProduce();
    Get.snackbar('Success', 'Product added successfully');
    //tgk balik ni
    imageUrls.clear();
    Get.back();
  } catch (e) {
    Get.snackbar('Error', 'Failed to add product: $e');
  }
}


  Future<void> fetchProduce() async {
  final loginController = Get.find<LoginController>();
  String? role = await loginController.getUserRole();
  print('User Role: $role');
  if (role == 'Seller') {
    try {
      // Fetch products for the current Seller using currentUserID
      final querySnapshot = await FirebaseFirestore.instance
          .collection('localProduce')
          .where(
            'userRef',
            isEqualTo: FirebaseFirestore.instance.collection('users').doc(currentUserID),
          )
          .get();

      final List<LocalProduce> produces = querySnapshot.docs.map((doc) {
        return LocalProduce.fromJson({
          ...doc.data(),
          'pid': doc.id,
        });
      }).toList();

      //iterate through produces and check if expiry date has passed
      for (var produce in produces) {
        if (produce.expiryDate.isBefore(DateTime.now()) && produce.status != 'recycled') {
          //update status
          produce.status = 'recycled';
          //update to firestore
          await FirebaseFirestore.instance.collection('localProduce').doc(produce.pid).update({
            'status': 'recycled',
          });
        }
      }

      produceList.assignAll(produces);
      filteredProduceList.assignAll(produceList);

      //Get.snackbar('Success', 'Products for Seller loaded successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch Seller products: $e');
      print('Error in fetchProduce for Seller: $e');
    }
  } else if (role == 'Customer') {
    
    try {
      // Fetch all products for Customers
      final querySnapshot = await FirebaseFirestore.instance
            .collection('localProduce')
            .where('status', isEqualTo: 'available')
            .get();

      final List<LocalProduce> produces = querySnapshot.docs.map((doc) {
        return LocalProduce.fromJson({
          ...doc.data(),
          'pid': doc.id,
        });
      }).toList();

       //iterate through produces and check if expiry date has passed
      for (var produce in produces) {
        if (produce.expiryDate.isBefore(DateTime.now()) && produce.status != 'recycled') {
          //update status
          produce.status = 'recycled';
          //update to firestore
          await FirebaseFirestore.instance.collection('localProduce').doc(produce.pid).update({
            'status': 'recycled',
          });
        }
        //if stock is 0, set to out of stock and update firestore
        if (produce.stock == 0 && produce.status != 'out of stock') {
          produce.status = 'out of stock';

          //update firestore
          await FirebaseFirestore.instance.collection('localProduce').doc(produce.pid).update({
            'status': 'out of stock',
          });
        }
      }

      produces.removeWhere((produce) => produce.status == 'recycled' || produce.status == 'out of stock');
      produceList.assignAll(produces);
      filteredProduceList.assignAll(produceList);

      //Get.snackbar('Success', 'Products for Customer loaded successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch Customer products: $e');
      print('Error in fetchProduce for Customer: $e');
    }
  } else {
    print('Error: Role is not recognized or null');
  }
}

  Future<void> fetchRecycledProduce() async {
    try{
      //fetch produce with status recycled
      final querySnapshot = await FirebaseFirestore.instance
            .collection('localProduce')
            .where('status', isEqualTo: 'recycled')
            .get();
      
      final List<LocalProduce> recycledProduces = querySnapshot.docs.map((doc) {
        return LocalProduce.fromJson({
          ...doc.data(),
          'pid':doc.id,
        });
      }).toList();

      recycledProduceList.assignAll(recycledProduces);
    } catch (e) {
      print('Error in fetcRecycledProduce: $e');
    }
    
  }

  Future<void> deleteProductFromListing(String pid) async {
  try {
    LocalProduce deletedProduct = produceList.firstWhere((produce) => produce.pid == pid);

    DocumentReference productRef = FirebaseFirestore.instance.collection('localProduce').doc(deletedProduct.pid);
    await productRef.delete();

    // Remove from the local list
    produceList.remove(deletedProduct);
    //ni baru tambah
    filterProduce('');

    Get.snackbar('Success', 'Product deleted successfully');
  } catch (e) {
    Get.snackbar('Error', 'Failed to delete product: $e');
  }
}

void filterProduce(String query) {
  if(query.isEmpty){
    filteredProduceList.assignAll(produceList);
  } else{
    filteredProduceList.value = produceList.where((produce) => 
          produce.productName.toLowerCase().contains(query.toLowerCase())).toList();
  }
}

// Pick multiple images
  Future<void> pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFiles = await picker.pickMultiImage(); 

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
    //upload file and get snapshot
    final TaskSnapshot snapshot = await ref.putFile(File(filePath));

    // Ensure the upload task is complete
    if (snapshot.state == TaskState.success) {
      return await ref.getDownloadURL();
    } else {
      throw Exception('Upload failed with state: ${snapshot.state}');
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

//updateproduce
Future<void> updateProduce(String pid) async {
  try {
    // Get the product from the produceList based on the product ID (pid)
    LocalProduce produceToUpdate = produceList.firstWhere((produce) => produce.pid == pid);

    // Update the product in Firestore
    await FirebaseFirestore.instance.collection('localProduce').doc(pid).update({
      'productName': produceToUpdate.productName,
      'description': produceToUpdate.description,
      'price': produceToUpdate.price,
      'stock': produceToUpdate.stock,
      'expiryDate': produceToUpdate.expiryDate,
      'status': produceToUpdate.status,
    });

    // Reflect changes in the local list
    produceList.refresh();
    filteredProduceList.refresh();
    await fetchProduce();

    Get.snackbar('Success', 'Product updated successfully');
  } catch (e) {
    Get.snackbar('Error', 'Failed to update product: $e');
  }
}

Future<LocalProduce> viewProduceDetails(String pid) async {
  try{
    final doc = await FirebaseFirestore.instance
          .collection('localProduce')
          .doc(pid)
          .get();
    
    if (doc.exists) {
      return LocalProduce.fromJson({
        ...doc.data()!,
        'pid': doc.id,
      });
    } else {
      throw 'Produce not found';
    }
    } catch (e) {
      throw 'Failed to load produce details: $e';
    }
  }
}