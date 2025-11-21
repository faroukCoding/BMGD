import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notification_model.dart';

class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> initialize() async {
    await _requestPermission();
    await _getAndSaveToken();
    _setupForegroundHandler();
    _setupBackgroundHandler();
  }

  Future<void> _requestPermission() async {
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
  }

  Future<void> _getAndSaveToken() async {
    final token = await _messaging.getToken();
    final userId = FirebaseAuth.instance.currentUser?.uid;
    
    if (userId != null && token != null) {
      await _firestore.collection('users').doc(userId).update({
        'fcmToken': token,
        'tokenUpdatedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  void _setupForegroundHandler() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _saveNotificationToFirestore(message);
    });
  }

  void _setupBackgroundHandler() {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  static Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    // Handle background message
  }

  Future<void> _saveNotificationToFirestore(RemoteMessage message) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final notification = NotificationModel(
      id: '',
      userId: userId,
      title: message.notification?.title ?? '',
      body: message.notification?.body ?? '',
      orderId: message.data['orderId'],
      isRead: false,
      createdAt: DateTime.now(),
    );

    await _firestore.collection('notifications').add(notification.toMap());
  }

  Stream<List<NotificationModel>> getUserNotifications(String userId) {
    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => NotificationModel.fromMap(
                doc.data() as Map<String, dynamic>, doc.id))
            .toList());
  }

  Future<void> markAsRead(String notificationId) async {
    await _firestore.collection('notifications').doc(notificationId).update({
      'isRead': true,
    });
  }

  Future<void> sendNotificationToUser({
    required String userId,
    required String title,
    required String body,
    String? orderId,
  }) async {
    final notification = NotificationModel(
      id: '',
      userId: userId,
      title: title,
      body: body,
      orderId: orderId,
      isRead: false,
      createdAt: DateTime.now(),
    );

    await _firestore.collection('notifications').add(notification.toMap());
  }

  Future<void> sendNotificationToRole({
    required String role,
    required String title,
    required String body,
    String? orderId,
  }) async {
    final users = await _firestore
        .collection('users')
        .where('role', isEqualTo: role)
        .get();

    for (var user in users.docs) {
      await sendNotificationToUser(
        userId: user.id,
        title: title,
        body: body,
        orderId: orderId,
      );
    }
  }
}