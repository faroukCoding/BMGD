import 'package:cloud_firestore/cloud_firestore.dart';

class PayoutModel {
  final String id;
  final String affiliateId;
  final double amount;
  final String status;
  final DateTime requestedAt;
  final DateTime? processedAt;
  final String? adminNotes;
  final String? rejectionReason;

  PayoutModel({
    required this.id,
    required this.affiliateId,
    required this.amount,
    required this.status,
    required this.requestedAt,
    this.processedAt,
    this.adminNotes,
    this.rejectionReason,
  });

  Map<String, dynamic> toMap() {
    return {
      'affiliateId': affiliateId,
      'amount': amount,
      'status': status,
      'requestedAt': Timestamp.fromDate(requestedAt),
      'processedAt': processedAt != null ? Timestamp.fromDate(processedAt!) : null,
      'adminNotes': adminNotes,
      'rejectionReason': rejectionReason,
    };
  }

  factory PayoutModel.fromMap(Map<String, dynamic> map, String id) {
    return PayoutModel(
      id: id,
      affiliateId: map['affiliateId'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      status: map['status'] ?? 'pending',
      requestedAt: (map['requestedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      processedAt: (map['processedAt'] as Timestamp?)?.toDate(),
      adminNotes: map['adminNotes'],
      rejectionReason: map['rejectionReason'],
    );
  }

  String get statusText {
    const statusMap = {
      'pending': 'قيد الانتظار',
      'completed': 'تم التسليم',
      'rejected': 'مرفوضة',
    };
    return statusMap[status] ?? 'غير معروف';
  }

  Color get statusColor {
    const colorMap = {
      'pending': Colors.orange,
      'completed': Colors.green,
      'rejected': Colors.red,
    };
    return colorMap[status] ?? Colors.grey;
  }
}