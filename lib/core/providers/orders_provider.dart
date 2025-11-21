import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/order_model.dart';
import '../constants/app_constants.dart';

final ordersProvider = StreamProvider.family<List<OrderModel>, String?>((ref, String? userId) {
  Query query = FirebaseFirestore.instance.collection(AppConstants.ordersCollection);
  
  if (userId != null) {
    query = query.where('affiliateId', isEqualTo: userId);
  }
  
  query = query.orderBy('createdAt', descending: true);
  
  return query.snapshots().map((snapshot) {
    return snapshot.docs.map((doc) {
      return OrderModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    }).toList();
  });
});

final orderProvider = StreamProvider.family<OrderModel?, String>((ref, String orderId) {
  return FirebaseFirestore.instance
      .collection(AppConstants.ordersCollection)
      .doc(orderId)
      .snapshots()
      .map((doc) {
    if (doc.exists) {
      return OrderModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    }
    return null;
  });
});