import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/models/order_model.dart';
import '../../../core/services/notification_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CallCenterOrderCard extends StatelessWidget {
  final OrderModel order;

  const CallCenterOrderCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.surface,
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: order.statusColor,
          child: const Icon(Icons.phone, color: Colors.white),
        ),
        title: Text(order.customerName),
        subtitle: Text(order.customerPhone),
        trailing: IconButton(
          icon: const Icon(Icons.phone, color: AppColors.accent),
          onPressed: () => _callCustomer(),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('المنتج', order.productName ?? 'غير محدد'),
                _buildInfoRow('العنوان', order.address),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _confirmOrder(context),
                        icon: const Icon(Icons.check),
                        label: const Text('تم التأكيد'),
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _noResponse(context),
                        icon: const Icon(Icons.warning),
                        label: const Text('لا رد'),
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.warning),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: () => _showRejectionDialog(context),
                  icon: const Icon(Icons.cancel),
                  label: const Text('رفض الطلب'),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Future<void> _callCustomer() async {
    final url = 'tel:${order.customerPhone}';
    if (await canLaunch(url)) {
      await launch(url);
    }
  }

  Future<void> _confirmOrder(BuildContext context) async {
    await _updateStatus(context, 'call_center_confirmed');
    
    // إشعار للمسوّق
    await NotificationService().sendNotificationToUser(
      userId: order.affiliateId,
      title: 'تم تأكيد طلبك عبر الهاتف',
      body: 'طلب #${order.id.substring(0, 8)} تم تأكيده',
      orderId: order.id,
    );
  }

  Future<void> _noResponse(BuildContext context) async {
    await _updateStatus(context, AppConstants.statusNoResponse);
  }

  Future<void> _showRejectionDialog(BuildContext context) async {
    final controller = TextEditingController();
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('سبب الرفض'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'اكتب سبب رفض الطلب',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('رفض'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _updateStatus(context, AppConstants.statusRejected, notes: controller.text);
    }
  }

  Future<void> _updateStatus(BuildContext context, String status, {String? notes}) async {
    final updateData = {
      'status': status,
      'callCenterId': FirebaseAuth.instance.currentUser?.uid,
      'callCenterNotes': notes ?? '',
      'reviewedAt': FieldValue.serverTimestamp(),
    };

    await FirebaseFirestore.instance
        .collection(AppConstants.ordersCollection)
        .doc(order.id)
        .update(updateData);

    if (context.mounted) {
      Navigator.pop(context);
    }
  }
}