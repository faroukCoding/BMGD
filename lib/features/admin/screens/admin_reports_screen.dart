import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminReportsScreen extends ConsumerStatefulWidget {
  const AdminReportsScreen({super.key});

  @override
  ConsumerState createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends ConsumerState<AdminReportsScreen> {
  String _selectedPeriod = 'month';
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('التقارير والإحصائيات'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'export_csv') _exportToCSV();
              if (value == 'export_pdf') _exportToPDF();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'export_csv',
                child: Text('تصدير CSV'),
              ),
              const PopupMenuItem(
                value: 'export_pdf',
                child: Text('تصدير PDF'),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ملخص عام
            _buildSummaryCards(),
            const SizedBox(height: 32),
            
            // الرسوم البيانية
            Text(
              'الرسوم البيانية',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            
            _buildOrdersByStatusChart(),
            const SizedBox(height: 24),
            
            _buildMonthlyCommissionsChart(),
            const SizedBox(height: 24),
            
            _buildTopAffiliatesChart(),
            const SizedBox(height: 24),
            
            _buildTopProductsChart(),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards() {
    return StreamBuilder<QuerySnapshot>(
      stream: _getOrdersStream(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final orders = snapshot.data!.docs;
        double totalCommissions = 0;
        int deliveredOrders = 0;
        int pendingOrders = 0;

        for (final doc in orders) {
          final data = doc.data() as Map<String, dynamic>;
          totalCommissions += (data['commission'] ?? 0) as double;
          if (data['status'] == AppConstants.statusDelivered) {
            deliveredOrders++;
          } else if (data['status'] == AppConstants.statusPending) {
            pendingOrders++;
          }
        }

        return Row(
          children: [
            Expanded(
              child: _SummaryCard(
                title: 'إجمالي العمولات',
                value: '${totalCommissions.toStringAsFixed(2)} ر.س',
                color: AppColors.accent,
                icon: Icons.payments,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _SummaryCard(
                title: 'طلبات مكتملة',
                value: deliveredOrders.toString(),
                color: AppColors.success,
                icon: Icons.check_circle,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildOrdersByStatusChart() {
    return Card(
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'الطلبات حسب الحالة',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: StreamBuilder<QuerySnapshot>(
                stream: _getOrdersStream(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final data = _processOrdersByStatus(snapshot.data!.docs);
                  
                  return BarChart(
                    BarChartData(
                      barGroups: data.entries.map((entry) {
                        return BarChartGroupData(
                          x: entry.key,
                          barRods: [
                            BarChartRodData(toY: entry.value.toDouble(), color: AppColors.accent)
                          ],
                        );
                      }).toList(),
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              const statuses = ['معلق', 'مؤكد', 'تم التسليم', 'مرفوض'];
                              return Text(statuses[value.toInt()]);
                            },
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlyCommissionsChart() {
    return Card(
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'العمولات الشهرية',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  lineBarsData: [
                    LineChartBarData(
                      spots: [
                        const FlSpot(0, 1000),
                        const FlSpot(1, 1500),
                        const FlSpot(2, 1200),
                        const FlSpot(3, 2000),
                      ],
                      isCurved: true,
                      color: AppColors.success,
                      barWidth: 3,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopAffiliatesChart() {
    return Card(
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'أفضل المسوقين',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 150,
              child: StreamBuilder<QuerySnapshot>(
                stream: _getOrdersStream(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final data = _processTopAffiliates(snapshot.data!.docs);
                  
                  return BarChart(
                    BarChartData(
                      barGroups: data.entries.map((entry) {
                        return BarChartGroupData(
                          x: data.keys.toList().indexOf(entry.key),
                          barRods: [
                            BarChartRodData(toY: entry.value, color: AppColors.accent)
                          ],
                        );
                      }).toList(),
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              final affiliates = data.keys.toList();
                              return Text(affiliates[value.toInt()]);
                            },
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopProductsChart() {
    return Card(
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'المنتجات الأكثر مبيعاً',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(
                      value: 40,
                      title: 'منتج أ',
                      color: AppColors.accent,
                    ),
                    PieChartSectionData(
                      value: 30,
                      title: 'منتج ب',
                      color: AppColors.success,
                    ),
                    PieChartSectionData(
                      value: 20,
                      title: 'منتج ج',
                      color: AppColors.warning,
                    ),
                    PieChartSectionData(
                      value: 10,
                      title: 'منتج د',
                      color: AppColors.error,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Stream<QuerySnapshot> _getOrdersStream() {
    return FirebaseFirestore.instance
        .collection(AppConstants.ordersCollection)
        .where('createdAt', isGreaterThan: _startDate)
        .where('createdAt', isLessThan: _endDate)
        .snapshots();
  }

  Map<String, int> _processOrdersByStatus(List<QueryDocumentSnapshot> docs) {
    final Map<String, int> data = {
      AppConstants.statusPending: 0,
      AppConstants.statusConfirmed: 0,
      AppConstants.statusDelivered: 0,
      AppConstants.statusRejected: 0,
    };

    for (final doc in docs) {
      final status = doc['status'] as String;
      if (data.containsKey(status)) {
        data[status] = data[status]! + 1;
      }
    }

    return data;
  }

  Map<String, double> _processTopAffiliates(List<QueryDocumentSnapshot> docs) {
    final Map<String, double> data = {};

    for (final doc in docs) {
      final affiliateId = doc['affiliateId'] as String;
      final commission = (doc['commission'] ?? 0) as double;
      data[affiliateId] = (data[affiliateId] ?? 0) + commission;
    }

    // أخذ أفضل 5 فقط
    final sorted = Map.fromEntries(
      data.entries.toList()..sort((a, b) => b.value.compareTo(a.value))
    );
    return Map.fromEntries(sorted.entries.take(5));
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('فلترة التقارير'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('آخر 7 أيام'),
              onTap: () {
                setState(() {
                  _startDate = DateTime.now().subtract(const Duration(days: 7));
                  _endDate = DateTime.now();
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('آخر 30 يوماً'),
              onTap: () {
                setState(() {
                  _startDate = DateTime.now().subtract(const Duration(days: 30));
                  _endDate = DateTime.now();
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('آخر 3 أشهر'),
              onTap: () {
                setState(() {
                  _startDate = DateTime.now().subtract(const Duration(days: 90));
                  _endDate = DateTime.now();
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _exportToCSV() {
    // تنفيذ تصدير CSV
  }

  void _exportToPDF() {
    // تنفيذ تصدير PDF
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
    return Card(
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 28),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}