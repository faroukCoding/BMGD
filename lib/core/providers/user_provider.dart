import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

final userProvider = StateNotifierProvider<UserNotifier, UserModel?>((ref) {
  return UserNotifier();
});

class UserNotifier extends StateNotifier<UserModel?> {
  UserNotifier() : super(null) {
    _loadCurrentUser();
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _loadCurrentUser() async {
    final user = _auth.currentUser;
    if (user != null) {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        state = UserModel.fromFirestore(doc);
      }
    }
  }

  Future<void> refreshUser() async {
    await _loadCurrentUser();
  }

  bool hasPermission(String permission) {
    if (state == null) return false;
    return _checkPermission(state!.role, permission);
  }

  bool _checkPermission(String role, String permission) {
    final permissions = _rolePermissions[role] ?? [];
    return permissions.contains('*') || permissions.contains(permission);
  }

  static const Map<String, List<String>> _rolePermissions = {
    'admin': ['*'],
    'assistant': ['review_orders', 'view_commissions', 'view_users'],
    'affiliate': ['add_order', 'view_own_orders', 'request_payout'],
    'call_center': ['confirm_orders', 'add_notes'],
    'driver': ['view_assigned_orders', 'update_status'],
  };
}