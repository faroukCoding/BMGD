import '../constants/app_constants.dart';

class RoleChecker {
  static bool hasPermission(String role, String permission) {
    final permissions = _rolePermissions[role] ?? [];
    return permissions.contains('*') || permissions.contains(permission);
  }

  static const Map<String, List<String>> _rolePermissions = {
    AppConstants.roleAdmin: ['*'],
    AppConstants.roleAssistant: [
      'review_orders',
      'view_commissions',
      'view_users',
      'manage_orders',
    ],
    AppConstants.roleAffiliate: [
      'add_order',
      'view_own_orders',
      'request_payout',
      'view_payout_history',
    ],
    AppConstants.roleCallCenter: [
      'confirm_orders',
      'add_notes',
      'view_commission',
    ],
    AppConstants.roleDriver: [
      'view_assigned_orders',
      'update_status',
      'add_notes',
    ],
  };

  static bool isAdmin(String role) => role == AppConstants.roleAdmin;
  static bool isAssistant(String role) => role == AppConstants.roleAssistant;
  static bool isAffiliate(String role) => role == AppConstants.roleAffiliate;
  static bool isCallCenter(String role) => role == AppConstants.roleCallCenter;
  static bool isDriver(String role) => role == AppConstants.roleDriver;
}