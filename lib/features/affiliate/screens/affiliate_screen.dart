import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/models/order_model.dart';
import 'add_order_screen.dart';
import 'payout_history_screen.dart';
import 'withdraw_request_screen.dart';

class AffiliateScreen extends ConsumerWidget {
  const AffiliateScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('لوحة المسوّق'),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.bell, color: AppColors.textPrimary),
            onPressed: () => Navigator.pushNamed(context, '/notifications'),
          ),
          IconButton(
            icon: const Icon(LucideIcons.settings, color: AppColors.textPrimary),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // بطاقات الملخص
            _buildSummaryCards(userId),
            const SizedBox(height: 24),

            // زر إضافة طلب
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddOrderScreen()),
                ),
                icon: const Icon(LucideIcons.plusCircle, size: 24),
                label: const Text(
                  'إضافة طلب جديد',
                  style: TextStyle(fontSize: 18),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // أحدث الطلبات
            Text(
              'أحدث الطلبات',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            _buildRecentOrders(userId),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildSummaryCards(String userId) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection(AppConstants.ordersCollection)
          .where('affiliateId', isEqualTo: userId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();

        final orders = snapshot.data!.docs
            .map((doc) => OrderModel.fromMap(doc.data() as Map<String, dynamic>(), doc.id))
            .toList();

        double totalCommissions = 0;
        double confirmedCommissions = 0;
        double pendingCommissions = 0;

        for (final order in orders) {
          totalCommissions += order.commission;
          if (order.status == AppConstants.statusDelivered) {
            confirmedCommissions += order.commission;
          } else if (order.status == AppConstants.statusPending || order.status == AppConstants.statusConfirmed) {
            pendingCommissions += order.commission;
          }
        }

        return Row(
          children: [
            Expanded(child: _SummaryCard(
              title: 'إجمالي العمولات',
              value: '${totalCommissions.toStringAsFixed(2)} ر.س',
              color: AppColors.accent,
              icon: LucideIcons.wallet,
            )),
            const SizedBox(width: 16),
            Expanded(child: _SummaryCard(
              title: 'المؤكدة',
              value: '${confirmedCommissions.toStringAsFixed(2)} ر.س',
              color: AppColors.success,
              icon: LucideIcons.checkCircle,
            )),
            const SizedBox(width: 16),
            Expanded(child: _SummaryCard(
              title: 'المعلقة',
              value: '${pendingCommissions.toStringAsFixed(2)} ر.س',
              color: AppColors.warning,
              icon: LucideIcons.clock,
            )),
          ],
        );
      },
    );
  }

  Widget _buildRecentOrders(String userId) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection(AppConstants.ordersCollection)
          .where('affiliateId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(5)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

        final orders = snapshot.data!.docs
            .map((doc) => OrderModel.fromMap(doc.data() as Map<String, dynamic>(), doc.id))
            .toList();

        if (orders.isEmpty) {
          return Center(
            child: Column(
              children: [
                Icon(LucideIcons.package, size: 64, color: AppColors.textSecondary),
                const SizedBox(height: 16),
                Text(
                  'لا توجد طلبات حتى الآن',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final order = orders[index];
            return _OrderItem(order: order);
          },
        );
      },
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: AppColors.surface,
      selectedItemColor: AppColors.accent,
      unselectedItemColor: AppColors.textSecondary,
      currentIndex: 0,
      onTap: (index) {
        switch (index) {
          case 0:
            // الرئيسية
            break;
          case 1:
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PayoutHistoryScreen()),
            );
            break;
          case 2:
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const WithdrawRequestScreen()),
            );
            break;
          case 3:
            Navigator.pushNamed(context, '/settings');
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(LucideIcons.home),
          label: 'الرئيسية',
        ),
        BottomNavigationBarItem(
          icon: Icon(LucideIcons.fileText),
          label: 'سجل الدفعات',
        ),
        BottomNavigationBarItem(
          icon: Icon(LucideIcons.arrowUpRight),
          label: 'طلب سحب',
        ),
        BottomNavigationBarItem(
          icon: Icon(LucideIcons.settings),
          label: 'الإعدادات',
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final IconData icon;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderItem extends StatelessWidget {
  final OrderModel order;

  const _OrderItem({required this.order});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.surface,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: order.statusColor,
          child: Icon(
            _getStatusIcon(order.status),
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(order.customerName),
        subtitle: Text(order.productName ?? 'منتج غير محدد'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${order.commission} ر.س',
              style: TextStyle(
                color: AppColors.accent,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              order.statusText,
              style: TextStyle(
                color: order.statusColor,
                fontSize: 12,
              ),
            ),
          ],
        ),
        onTap: () => Navigator.pushNamed(
          context,
          '/order-details',
          arguments: order.id,
        ),
      ),
    );
  }

  IconData _getStatusIcon(String status) {
    final icons = {
      AppConstants.statusPending: LucideIcons.clock,
      AppConstants.statusConfirmed: LucideIcons.checkCircle,
      AppConstants.statusDelivered: LucideIcons.check,
      AppConstants.statusRejected: LucideIcons.xCircle,
      AppConstants.statusInDelivery: LucideIcons.truck,
      AppConstants.statusFailed: LucideIcons.ban,
      AppConstants.statusNoResponse: LucideIcons.alertTriangle,
    };
    return icons[status] ?? LucideIcons.helpCircle;
  }
}