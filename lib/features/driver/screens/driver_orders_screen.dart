import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/models/order_model.dart';
import '../widgets/driver_order_card.dart';

class DriverOrdersScreen extends ConsumerWidget {
  const DriverOrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final driverId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('طلبات التوصيل'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.refresh(ordersProvider(null)),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection(AppConstants.ordersCollection)
            .where('driverId', isEqualTo: driverId)
            .where('status', whereIn: [
              AppConstants.statusConfirmed,
              AppConstants.statusInDelivery,
            ])
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final orders = snapshot.data!.docs
              .map((doc) => OrderModel.fromMap(doc.data() as Map<String, dynamic>(), doc.id))
              .toList();

          if (orders.isEmpty) {
            return const Center(child: Text('لا توجد طلبات موكلة إليك'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              return DriverOrderCard(order: orders[index]);
            },
          );
        },
      ),
    );
  }
}