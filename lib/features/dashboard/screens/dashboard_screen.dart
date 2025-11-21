import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/providers/user_provider.dart';
import '../../../shared/widgets/role_bottom_nav.dart';
import 'dashboard_content.dart';

class DashboardScreen extends ConsumerWidget {
  final String role;

  const DashboardScreen({super.key, required this.role});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_getAppBarTitle()),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () => Navigator.pushNamed(context, '/notifications'),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
          if (user != null) ...[
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) {
                if (value == 'logout') {
                  _handleLogout(context, ref);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'logout',
                  child: Text('تسجيل الخروج'),
                ),
              ],
            ),
          ],
        ],
      ),
      body: _buildDashboardContent(),
      bottomNavigationBar: RoleBottomNav(currentRole: role),
    );
  }

  Widget _buildDashboardContent() {
    switch (role) {
      case AppConstants.roleAdmin:
        return const AdminDashboardContent();
      case AppConstants.roleAssistant:
        return const AssistantDashboardContent();
      case AppConstants.roleAffiliate:
        return const AffiliateDashboardContent();
      case AppConstants.roleCallCenter:
        return const CallCenterDashboardContent();
      case AppConstants.roleDriver:
        return const DriverDashboardContent();
      default:
        return const Center(child: Text('دور غير معروف'));
    }
  }

  String _getAppBarTitle() {
    const titles = {
      AppConstants.roleAdmin: 'لوحة المدير',
      AppConstants.roleAssistant: 'لوحة المساعد الإداري',
      AppConstants.roleAffiliate: 'لوحة المسوّق',
      AppConstants.roleCallCenter: 'لوحة مؤكد الطلبات',
      AppConstants.roleDriver: 'لوحة السائق',
    };
    return titles[role] ?? 'الرئيسية';
  }

  Future<void> _handleLogout(BuildContext context, WidgetRef ref) async {
    final authService = ref.read(authServiceProvider);
    await authService.signOut();
    Navigator.pushReplacementNamed(context, '/login');
  }
}

// استبدل هذا بالـ Navigation Navigator
class AuthService {
  Future<void> signOut() async {
    // تنفيذ تسجيل الخروج
  }
}

final authServiceProvider = Provider((ref) => AuthService());