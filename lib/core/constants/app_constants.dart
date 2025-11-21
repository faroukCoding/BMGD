class AppConstants {
  static const String appName = 'BMG Corp';
  static const String version = '1.0.0';
  
  // Collection names
  static const String usersCollection = 'users';
  static const String ordersCollection = 'orders';
  static const String productsCollection = 'products';
  static const String payoutsCollection = 'payouts';
  static const String commissionsCollection = 'commissions';
  static const String notificationsCollection = 'notifications';

  // User roles
  static const String roleAdmin = 'admin';
  static const String roleAssistant = 'assistant';
  static const String roleAffiliate = 'affiliate';
  static const String roleCallCenter = 'call_center';
  static const String roleDriver = 'driver';

  // Order statuses
  static const String statusPending = 'pending';
  static const String statusConfirmed = 'confirmed';
  static const String statusRejected = 'rejected';
  static const String statusPendingAdmin = 'pending_admin';
  static const String statusInDelivery = 'in_delivery';
  static const String statusDelivered = 'delivered';
  static const String statusFailed = 'failed';
  static const String statusNoResponse = 'no_response';

  // Payout statuses
  static const String payoutPending = 'pending';
  static const String payoutCompleted = 'completed';
  static const String payoutRejected = 'rejected';
}