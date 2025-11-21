import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WhatsAppService {
  static Future<void> launchWhatsApp({
    required String phoneNumber,
    String? message,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    final userName = user?.displayName ?? 'المستخدم';
    
    String defaultMessage = 'مرحبًا، أنا $userName، أحتاج المساعدة';
    if (message != null) {
      defaultMessage += ' $message';
    }

    final url = 'https://wa.me/$phoneNumber?text=${Uri.encodeComponent(defaultMessage)}';
    
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'لا يمكن فتح WhatsApp';
    }
  }

  static Future<void> launchSupportChat({String? orderId}) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    
    final role = userDoc.data()?['role'] ?? 'affiliate';
    final supportNumber = _getSupportNumber(role);
    
    String message = '';
    if (orderId != null) {
      message = 'بخصوص الطلب رقم $orderId';
    }

    await launchWhatsApp(
      phoneNumber: supportNumber,
      message: message,
    );
  }

  static String _getSupportNumber(String role) {
    const supportNumbers = {
      'admin': '+966500000000',
      'assistant': '+966500000001',
      'affiliate': '+966500000002',
      'call_center': '+966500000003',
      'driver': '+966500000004',
    };
    return supportNumbers[role] ?? '+966500000000';
  }

  static Future<void> launchAdminChat() async {
    await launchWhatsApp(
      phoneNumber: _getSupportNumber('admin'),
      message: 'تحية طيبة، أحتاج دعم تقني',
    );
  }
}