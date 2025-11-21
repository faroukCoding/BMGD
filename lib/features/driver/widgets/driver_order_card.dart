import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/models/order_model.dart';
import '../../../core/services/notification_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DriverOrderCard extends ConsumerWidget {
  final OrderModel order;

  const DriverOrderCard({super.key, required this.order});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      color: AppColors.surface,
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: order.statusColor,
          child: const Icon(Icons.delivery_dining, color: Colors.white),
        ),
        title: Text(order.customerName),
        subtitle: Text(order.address),
        trailing: PopupMenuButton<String>(
          onSelected: (value) async {
            if (value == 'view_location') {
              _openLocation();
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'view_location',
              child: Text('عرض على الخريطة'),
            ),
            const PopupMenuItem(
              value: 'call_customer',
              child: Text('الاتصال بالزبون'),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('الهاتف', order.customerPhone),
                _buildInfoRow('المنتج', order.productName ?? 'غير محدد'),
                _buildInfoRow('الحالة', order.statusText),
                if (order.driverNotes != null) ...[
                  const SizedBox(height: 8),
                  _buildInfoRow('ملاحظات', order.driverNotes!),
                ],
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: order.status == AppConstants.statusConfirmed
                            ? () => _updateStatus(context, ref, AppConstants.statusInDelivery)
                            : null,
                        icon: const Icon(Icons.delivery_dining),
                        label: const Text('في الطريق'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.warning,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _updateStatus(context, ref, AppConstants.statusDelivered),
                        icon: const Icon(Icons.check_circle),
                        label: const Text('تم التسليم'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.success,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: () => _showFailureDialog(context, ref),
                  icon: const Icon(Icons.cancel),
                  label: const Text('فشل التوصيل'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                  ),
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

  Future<void> _updateStatus(BuildContext context, WidgetRef ref, String status) async {
    final notesController = TextEditingController();
    
    if (status == AppConstants.statusFailed) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('سبب الفشل'),
          content: TextField(
            controller: notesController,
            decoration: const InputDecoration(
              hintText: 'اكتب سبب فشل التوصيل',
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
              child: const Text('تأكيد الفشل'),
            ),
          ],
        ),
      );

      if (confirmed != true) return;
    }

    final updateData = {
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (status == AppConstants.statusDelivered) {
      updateData['deliveredAt'] = FieldValue.serverTimestamp();
    }

    if (notesController.text.isNotEmpty) {
      updateData['driverNotes'] = notesController.text;
    }

    await FirebaseFirestore.instance
        .collection(AppConstants.ordersCollection)
        .doc(order.id)
        .update(updateData);

    // إشعار للمسوّق
    await NotificationService().sendNotificationToUser(
      userId: order.affiliateId,
      title: 'تم تحديث حالة الطلب',
      body: 'طلب #${order.id.substring(0, 8)}: ${order.statusText}',
      orderId: order.id,
    );
  }

  Future<void> _showFailureDialog(BuildContext context, WidgetRef ref) async {
    await _updateStatus(context, ref, AppConstants.statusFailed);
  }

  void _openLocation() {
    final address = order.address;
    final url = 'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(address)}';
    launch(url);
  }
}