import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/tracking_model.dart';

class TrackingApiService {
  // ⚙️ إعدادات API - عدّلها حسب المزود
  static const String _baseUrl = 'https://api.smsaexpress.com';
  static const String _apiKey = 'YOUR_API_KEY_HERE';
  
  // يمكنك تغيير المزود من هنا
  static const String _provider = 'smsa'; // 'aramex', 'zajil', 'fetchr', 'nael'

  /// ✅ تتبع طلب واحد
  Future<TrackingModel> trackOrder(String trackingNumber) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/tracking/$trackingNumber'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return TrackingModel.fromJson(data);
      } else {
        throw Exception('فشل التتبع: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('خطأ في الاتصال: $e');
    }
  }

  /// ✅ تتبع عدة طلبات دفعة واحدة
  Future<List<TrackingModel>> trackMultipleOrders(List<String> trackingNumbers) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/tracking/batch'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'trackingNumbers':