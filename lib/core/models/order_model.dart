import 'package:cloud_firestore/cloud_firestore.dart';

class OrderModel {
  final String id;
  final String affiliateId;
  final String? callCenterId;
  final String? driverId;
  final String customerName;
  final String customerPhone;
  final String address;
  final String productId;
  final String? productName;
  final String? productImageUrl;
  final double productPrice;
  final double commission;
  final String status;
  final String? callCenterNotes;
  final String? driverNotes;
  final String? adminNotes;
  final DateTime createdAt;
  final DateTime? confirmedAt;
  final DateTime? deliveredAt;
  final bool isSpecial;

  OrderModel({
    required this.id,
    required this.affiliateId,
    this.callCenterId,
    this.driverId,
    required this.customerName,
    required this.customerPhone,
    required this.address,
    required this.productId,
    this.productName,
    this.productImageUrl,
    required this.productPrice,
    required this.commission,
    required this.status,
    this.callCenterNotes,
    this.driverNotes,
    this.adminNotes,
    required this.createdAt,
    this.confirmedAt,
    this.deliveredAt,
    required this.isSpecial,
  });

  Map<String, dynamic> toMap() {
    return {
      'affiliateId': affiliateId,
      'callCenterId': callCenterId,
      'driverId': driverId,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'address': address,
      'productId': productId,
      'productName': productName,
      'productImageUrl': productImageUrl,
      'productPrice': productPrice,
      'commission': commission,
      'status': status,
      'callCenterNotes': callCenterNotes,
      'driverNotes': driverNotes,
      'adminNotes': adminNotes,
      'createdAt': Timestamp.fromDate(createdAt),
      'confirmedAt': confirmedAt != null ? Timestamp.fromDate(confirmedAt!) : null,
      'deliveredAt': deliveredAt != null ? Timestamp.fromDate(deliveredAt!) : null,
      'isSpecial': isSpecial,
    };
  }

  factory OrderModel.fromMap(Map<String, dynamic> map, String id) {
    return OrderModel(
      id: id,
      affiliateId: map['affiliateId'] ?? '',
      callCenterId: map['callCenterId'],
      driverId: map['driverId'],
      customerName: map['customerName'] ?? '',
      customerPhone: map['customerPhone'] ?? '',
      address: map['address'] ?? '',
      productId: map['productId'] ?? '',
      productName: map['productName'],
      productImageUrl: map['productImageUrl'],
      productPrice: (map['productPrice'] ?? 0).toDouble(),
      commission: (map['commission'] ?? 0).toDouble(),
      status: map['status'] ?? 'pending',
      callCenterNotes: map['callCenterNotes'],
      driverNotes: map['driverNotes'],
      adminNotes: map['adminNotes'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      confirmedAt: (map['confirmedAt'] as Timestamp?)?.toDate(),
      deliveredAt: (map['deliveredAt'] as Timestamp?)?.toDate(),
      isSpecial: map['isSpecial'] ?? false,
    );
  }

  String get statusText {
    const statusMap = {
      'pending': 'معلق',
      'pending_admin': 'ينتظر موافقة المدير',
      'confirmed': 'مؤكد',
      'rejected': 'مرفوض',
      'in_delivery': 'قيد التوصيل',
      'delivered': 'تم التسليم',
      'failed': 'فشل التوصيل',
      'no_response': 'لا رد',
    };
    return statusMap[status] ?? 'غير معروف';
  }

  Color get statusColor {
    const colorMap = {
      'pending': Colors.orange,
      'pending_admin': Colors.deepPurple,
      'confirmed': Colors.blue,
      'rejected': Colors.red,
      'in_delivery': Colors.indigo,
      'delivered': Colors.green,
      'failed': Colors.redAccent,
      'no_response': Colors.grey,
    };
    return colorMap[status] ?? Colors.grey;
  }
}