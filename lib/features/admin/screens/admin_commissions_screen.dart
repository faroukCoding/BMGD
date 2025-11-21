import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/models/payout_model.dart';

class AdminCommissionsScreen extends ConsumerWidget {
  const AdminCommissionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('إدارة العمولات والسحب'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'طلبات السحب', icon: Icon(Icons.request_page)),
              Tab(text: 'تمت الموافقة', icon: Icon(Icons.check_circle)),
              Tab(text: 'مرفوضة', icon: Icon(Icons.cancel)),
              Tab(text: 'سجل الدفعات', icon: Icon(Icons.history)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildPayoutsList(PayoutStatus.pending),
            _buildPayoutsList(PayoutStatus.completed),
            _buildPayoutsList(PayoutStatus.rejected),
            _buildPayoutsHistory(),
          ],
        ),
      ),
    );
  }

  Widget _buildPayoutsList(String status) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection(AppConstants.payoutsCollection)
          .where('status', isEqualTo: status)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final payouts = snapshot.data!.docs
            .map((doc) => PayoutModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
            .toList();

        if (payouts.isEmpty) {
          return const Center(child: Text('لا توجد بيانات'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: payouts.length,
          itemBuilder: (context, index) {
            final payout = payouts[index];
            return _PayoutCard(payout: payout);
          },
        );
      },
    );
  }

  Widget _buildPayoutsHistory() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection(AppConstants.payoutsCollection)
          .orderBy('processedAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final payouts = snapshot.data!.docs
            .map((doc) => PayoutModel.fromMap(doc.data() as Map<String, dynamic>(), doc.id))
            .toList();

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: payouts.length,
          itemBuilder: (context, index) {
            final payout = payouts[index];
            return _PayoutHistoryCard(payout: payout);
          },
        );
      },
    );
  }
}

class _PayoutCard extends StatelessWidget {
  final PayoutModel payout;

  const _PayoutCard({required this.payout});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.surface,
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        title: Text('طلب سحب #${payout.id.substring(0, 8)}'),
        subtitle: Text('المبلغ: ${payout.amount} ر.س'),
        trailing: Chip(
          label: Text(payout.statusText),
          backgroundColor: payout.statusColor,
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('المسوّق', payout.affiliateId),
                _buildInfoRow('المبلغ', '${payout.amount} ر.س'),
                _buildInfoRow('تاريخ الطلب', '${payout.requestedAt.day}/${payout.requestedAt.month}/${payout.requestedAt.year}'),
                if (payout.adminNotes != null) ...[
                  const SizedBox(height: 8),
                  _buildInfoRow('ملاحظات المدير', payout.adminNotes!),
                ],
                const SizedBox(height: 16),
                Row(
                  children: [
                    if (payout.status == PayoutStatus.pending) ...[
                      Expanded(
                        child: CustomButton(
                          text: 'موافقة',
                          onPressed: () => _processPayout(payout.id, true),
                          backgroundColor: AppColors.success,
                          size: ButtonSize.small,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: CustomButton(
                          text: 'رفض',
                          onPressed: () => _showRejectionDialog(context, payout.id),
                          backgroundColor: AppColors.error,
                          size: ButtonSize.small,
                        ),
                      ),
                    ],
                  ],
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

  Future<void> _processPayout(String payoutId, bool approve) async {
    final data = {
      'status': approve ? PayoutStatus.completed : PayoutStatus.rejected,
      'processedAt': FieldValue.serverTimestamp(),
    };

    await FirebaseFirestore.instance
        .collection(AppConstants.payoutsCollection)
        .doc(payoutId)
        .update(data);
  }

  Future<void> _showRejectionDialog(BuildContext context, String payoutId) async {
    final controller = TextEditingController();
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('سبب الرفض'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'اكتب سبب الرفض',
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
            child: const Text('رفض'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await FirebaseFirestore.instance
          .collection(AppConstants.payoutsCollection)
          .doc(payoutId)
          .update({
        'status': PayoutStatus.rejected,
        'adminNotes': controller.text,
        'processedAt': FieldValue.serverTimestamp(),
      });
    }
  }
}

class _PayoutHistoryCard extends StatelessWidget {
  final PayoutModel payout;

  const _PayoutHistoryCard({required this.payout});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.surface,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: payout.statusColor,
          child: Icon(
            payout.status == PayoutStatus.completed ? Icons.check : Icons.cancel,
            color: Colors.white,
          ),
        ),
        title: Text('دفعة #${payout.id.substring(0, 8)}'),
        subtitle: Text(
          'المبلغ: ${payout.amount} ر.س\n'
          'التاريخ: ${payout.processedAt?.day}/${payout.processedAt?.month}/${payout.processedAt?.year}',
        ),
        trailing: Chip(
          label: Text(payout.statusText),
          backgroundColor: payout.statusColor,
        ),
      ),
    );
  }
}

class PayoutStatus {
  static const String pending = 'pending';
  static const String completed = 'completed';
  static const String rejected = 'rejected';
}