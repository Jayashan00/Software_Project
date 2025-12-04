import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:bin_owner_mobile_app/config.dart';

class NotificationService {
  final _storage = const FlutterSecureStorage();

  Future<List<Map<String, dynamic>>> fetchNotifications() async {
    final token = await _storage.read(key: 'jwt_token');

    // ✅ Ensure URL is correct
    final url = '$baseUrl/notifications';

    print('🔔 Calling API: $url');

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      print('🔔 Response Code: ${response.statusCode}');
      print('🔔 Response Body: ${response.body}'); // <--- LOOK AT THIS IN CONSOLE

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);

        if (body['success'] == true && body['data'] != null) {
          final List<dynamic> data = body['data'];
          return List<Map<String, dynamic>>.from(data);
        } else {
          return [];
        }
      } else {
        return [];
      }
    } catch (e) {
      print('❌ Exception fetching notifications: $e');
      return [];
    }
  }

  Future<bool> markAsRead(String notificationId) async {
    final token = await _storage.read(key: 'jwt_token');
    final url = '$baseUrl/notifications/$notificationId/read';

    try {
      final response = await http.put(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Error marking read: $e');
      return false;
    }
  }
}