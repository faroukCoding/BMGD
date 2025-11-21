import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';
import '../constants/app_constants.dart';

final productsProvider = StreamProvider<List<ProductModel>>((ref) {
  return FirebaseFirestore.instance
      .collection(AppConstants.productsCollection)
      .where('isActive', isEqualTo: true)
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) {
      return ProductModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    }).toList();
  });
});

final productProvider = StreamProvider.family<ProductModel?, String>((ref, String productId) {
  return FirebaseFirestore.instance
      .collection(AppConstants.productsCollection)
      .doc(productId)
      .snapshots()
      .map((doc) {
    if (doc.exists) {
      return ProductModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    }
    return null;
  });
});