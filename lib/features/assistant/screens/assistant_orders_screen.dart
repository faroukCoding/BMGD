import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/providers/orders_provider.dart';
import '../../../core/models/order_model.dart';
import '../widgets/order_review_card.dart';

class AssistantOrdersScreen extends ConsumerWidget {
  const AssistantOrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('مراجعة الطلبات'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.pending), text: 'معلقة'),
              Tab(icon: Icon(Icons.check_circle), text: 'مؤكدة'),
              Tab(icon: Icon(Icons.cancel), text: 'مرفوضة'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildOrdersList(context, ref, AppConstants.statusPending),
            _buildOrdersList(context, ref, AppConstants.statusConfirmed),
            _buildOrdersList(context, ref, AppConstants.statusRejected),
          ],
        ),
      ),
    );
  }

  Widget _buildOrdersList(BuildContext context, WidgetRef ref, String status) {
    final ordersAsync = ref.watch(ordersProvider(null));

    return ordersAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('خطأ: $error')),
      data: (orders) {
        final filteredOrders = orders.where((order) => order.status == status).toList();

        if (filteredOrders.isEmpty) {
          return const Center(child: Text('لا توجد طلبات'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: filteredOrders.length,
          itemBuilder: (context, index) {
            return OrderReviewCard(order: filteredOrders[index]);
          },
        );
      },
    );
  }
}