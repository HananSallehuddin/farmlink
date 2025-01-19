import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farmlink/controllers/RatingController.dart';
import 'package:farmlink/models/Rating.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class rateProduceFormUI extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final ratingController = Get.find<RatingController>();
  int? score;
  String? review;

  @override
  Widget build(BuildContext context) {
    // Get the pid parameter passed from the previous screen
    final String? pid = Get.parameters['pid'];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Get.back();
          },
        ),
        title: Text("Add rating for this produce"),
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
                labelText: 'Score',
                hintText: 'Enter score for the produce',
                onSaved: (value) => score = int.tryParse(value!),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 16),
              _buildTextFormField(
                labelText: 'Review',
                hintText: 'Leave review for the produce',
                onSaved: (value) => review = value,
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    String rid = FirebaseFirestore.instance.collection('ratings').doc().id;
                    DocumentSnapshot produceSnapshot = await FirebaseFirestore.instance.collection('localProduce').doc(pid).get();
                    DocumentReference sellerRef = produceSnapshot['userRef'];  // The sellerRef is stored in the userRef field

                    Rating newRating = Rating( 
                      rid: rid,
                      score: score!,
                      review: review!,
                      customerRef: FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid),
                      dateRated: DateTime.now(),
                      sellerRef: sellerRef,
                      produceRef: FirebaseFirestore.instance.collection('localProduce').doc(pid),
                      type: 'produce',
                    );

                    // Use the pid to add the rating
                    await ratingController.addProduceRating(pid!, newRating);
                    Get.back(); // Go back after saving the rating
                  }
                },
                child: Text('Save rating'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required String labelText,
    required String hintText,
    required FormFieldSetter<String> onSaved,
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
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a value';
        }
        return null;
      },
      onSaved: onSaved,
      autovalidateMode: AutovalidateMode.onUserInteraction,
    );
  }
}