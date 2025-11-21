import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/models/order_model.dart';
import '../../../core/services/notification_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrderReviewCard extends ConsumerWidget {
  final OrderModel order;

  const OrderReviewCard({super.key, required this.order});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      color: AppColors.surface,
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: order.statusColor,
          child: Icon(_getStatusIcon(order.status), color: Colors.white),
        ),
        title: Text(order.customerName),
        subtitle: Text('${order.customerPhone}\n${order.productName ?? 'منتج مخصص'}'),
        trailing: _buildActionButtons(context, ref),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('العنوان', order.address),
                _buildInfoRow('المبلغ', '${order.productPrice} ر.س'),
                _buildInfoRow('العمولة', '${order.commission} ر.س'),
                if (order.notes != null) ...[
                  const SizedBox(height: 8),
                  _buildInfoRow('ملاحظات', order.notes!),
                ],
                if (order.productImageUrl != null) ...[
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      order.productImageUrl!,
                      height: 100,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                if (order.status == AppConstants.statusPending) ...[
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _confirmOrder(context, ref),
                          icon: const Icon(Icons.check),
                          label: const Text('تأكيد'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.success,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _rejectOrder(context, ref),
                          icon: const Icon(Icons.close),
                          label: const Text('رفض'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, WidgetRef ref) {
    return PopupMenuButton<String>(
      onSelected: (value) async {
        if (value == 'view_details') {
          Navigator.pushNamed(context, '/order-details', arguments: order.id);
        } else if (value == 'contact_customer') {
          await _callCustomer();
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'view_details',
          child: Text('عرض التفاصيل'),
        ),
        const PopupMenuItem(
          value: 'contact_customer',
          child: Text('الاتصال بالزبون'),
        ),
      ],
    );
  }

  IconData _getStatusIcon(String status) {
    final icons = {
      AppConstants.statusPending: Icons.pending,
      AppConstants.statusConfirmed: Icons.check_circle,
      AppConstants.statusRejected: Icons.cancel,
    };
    return icons[status] ?? Icons.help;
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
            child: Text(value, style: const TextStyle(color: AppColors.textPrimary)),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmOrder(BuildContext context, WidgetRef ref) async {
    await _updateOrderStatus(AppConstants.statusConfirmed);
    
    // إشعار للمسوّق
    await NotificationService().sendNotificationToUser(
      userId: order.affiliateId,
      title: 'تم تأكيد طلبك',
      body: 'تم تأكيد طلب #${order.id.substring(0, 8)}',
      orderId: order.id,
    );
  }

  Future<void> _rejectOrder(BuildContext context, WidgetRef ref) async {
    final reasonController = TextEditingController();
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('سبب الرفض'),
        content: TextField(
          controller: reasonController,
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
      await _updateOrderStatus(AppConstants.statusRejected, adminNotes: reasonController.text);
      
      // إشعار للمسوّق
      await NotificationService().sendNotificationToUser(
        userId: order.affiliateId,
        title: 'تم رفض طلبك',
        body: reasonController.text,
        orderId: order.id,
      );
    }
  }

  Future<void> _updateOrderStatus(String status, {String? adminNotes}) async {
    final updateData = {
      'status': status,
      'reviewedAt': FieldValue.serverTimestamp(),
    };
    
    if (adminNotes != null) {
      updateData['adminNotes'] = adminNotes;
    }

    await FirebaseFirestore.instance
        .collection(AppConstants.ordersCollection)
        .doc(order.id)
        .update(updateData);
  }

  Future<void> _callCustomer() async {
    final phone = order.customerPhone;
    final url = 'tel:$phone';
    
    if (await canLaunch(url)) {
      await launch(url);
    }
  }
}