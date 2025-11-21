import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';

class RoleBottomNav extends StatelessWidget {
  final String currentRole;
  final int currentIndex;
  final Function(int)? onTap;

  const RoleBottomNav({
    super.key,
    required this.currentRole,
    this.currentIndex = 0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap ?? (index) => _navigateToPage(context, index),
      backgroundColor: AppColors.primary,
      selectedItemColor: AppColors.accent,
      unselectedItemColor: AppColors.textSecondary,
      type: BottomNavigationBarType.fixed,
      items: _getNavItems(),
    );
  }

  List<BottomNavigationBarItem> _getNavItems() {
    switch (currentRole) {
      case AppConstants.roleAffiliate:
        return [
          const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'الرئيسية'),
          const BottomNavigationBarItem(icon: Icon(Icons.add_circle), label: 'إضافة طلب'),
          const BottomNavigationBarItem(icon: Icon(Icons.history), label: 'سجل الطلبات'),
          const BottomNavigationBarItem(icon: Icon(Icons.wallet), label: 'العمولات'),
        ];
      
      case AppConstants.roleAssistant:
        return [
          const BottomNavigationBarItem(icon: Icon(Icons.pending), label: 'معلقة'),
          const BottomNavigationBarItem(icon: Icon(Icons.check), label: 'مؤكدة'),
          const BottomNavigationBarItem(icon: Icon(Icons.cancel), label: 'مرفوضة'),
        ];
      
      case AppConstants.roleDriver:
        return [
          const BottomNavigationBarItem(icon: Icon(Icons.list), label: 'طلباتي'),
          const BottomNavigationBarItem(icon: Icon(Icons.map), label: 'الخريطة'),
          const BottomNavigationBarItem(icon: Icon(Icons.history), label: 'السجل'),
        ];
      
      case AppConstants.roleCallCenter:
        return [
          const BottomNavigationBarItem(icon: Icon(Icons.phone), label: 'للاتصال'),
          const BottomNavigationBarItem(icon: Icon(Icons.check), label: 'مؤكدة'),
          const BottomNavigationBarItem(icon: Icon(Icons.warning), label: 'لا رد'),
        ];
      
      default:
        return [
          const BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'لوحة التحكم'),
          const BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'الإعدادات'),
        ];
    }
  }

  void _navigateToPage(BuildContext context, int index) {
    // سيتم تطبيق التنقل بناءً على الدور
    // يمكن تخصيص هذا الجزء حسب الحاجة
  }
}