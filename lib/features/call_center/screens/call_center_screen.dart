import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/models/order_model.dart';
import '../widgets/call_center_order_card.dart';

class CallCenterScreen extends ConsumerWidget {
  const CallCenterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('تأكيد الطلبات'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.phone), text: 'للاتصال'),
              Tab(icon: Icon(Icons.check), text: 'مؤكدة'),
              Tab(icon: Icon(Icons.cancel), text: 'لا رد'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildOrdersList(context, ref, AppConstants.statusConfirmed),
            _buildOrdersList(context, ref, 'call_center_confirmed'),
            _buildOrdersList(context, ref, AppConstants.statusNoResponse),
          ],
        ),
      ),
    );
  }

  Widget _buildOrdersList(BuildContext context, WidgetRef ref, String status) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection(AppConstants.ordersCollection)
          .where('callCenterId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
          .where('status', isEqualTo: status)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final orders = snapshot.data!.docs
            .map((doc) => OrderModel.fromMap(doc.data() as Map<String, dynamic>(), doc.id))
            .toList();

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: orders.length,
          itemBuilder: (context, index) {
            return CallCenterOrderCard(order: orders[index]);
          },
        );
      },
    );
  }
}