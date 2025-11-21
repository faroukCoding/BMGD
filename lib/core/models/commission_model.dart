import 'package:cloud_firestore/cloud_firestore.dart';

class CommissionModel {
  final String id;
  final String orderId;
  final String affiliateId;
  final String? callCenterId;
  final double affiliateCommission;
  final double? callCenterCommission;
  final DateTime createdAt;
  final bool isPaid;

  CommissionModel({
    required this.id,
    required this.orderId,
    required this.affiliateId,
    this.callCenterId,
    required this.affiliateCommission,
    this.callCenterCommission,
    required this.createdAt,
    required this.isPaid,
  });

  Map<String, dynamic> toMap() {
    return {
      'orderId': orderId,
      'affiliateId': affiliateId,
      'callCenterId': callCenterId,
      'affiliateCommission': affiliateCommission,
      'callCenterCommission': callCenterCommission,
      'createdAt': Timestamp.fromDate(createdAt),
      'isPaid': isPaid,
    };
  }

  factory CommissionModel.fromMap(Map<String, dynamic> map, String id) {
    return CommissionModel(
      id: id,
      orderId: map['orderId'] ?? '',
      affiliateId: map['affiliateId'] ?? '',
      callCenterId: map['callCenterId'],
      affiliateCommission: (map['affiliateCommission'] ?? 0).toDouble(),
      callCenterCommission: map['callCenterCommission']?.toDouble(),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isPaid: map['isPaid'] ?? false,
    );
  }
}