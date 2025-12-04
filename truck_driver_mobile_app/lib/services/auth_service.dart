import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:truck_driver_mobile_app/config.dart'; // ✅ Import Config

class AuthService {
  // ❌ REMOVED Hardcoded URL
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  Future<bool> login(String id, String password) async {
    // ✅ Use baseUrl from config
    final url = Uri.parse('$baseUrl/auth/authenticate');

    try {
      final response = await http.post(
        url,
        headers: const {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': id,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);

        if (jsonResponse['success'] == true) {
          final token = jsonResponse['data']?['token'];
          if (token != null) {
            await _secureStorage.write(key: 'jwt_token', value: token);
            return true;
          }
        }

        print("Login failed: ${jsonResponse['message'] ?? 'Unknown error'}");
        return false;
      } else {
        print("HTTP error: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print("Login exception: $e");
      return false;
    }
  }

  Future<String?> getToken() async {
    return await _secureStorage.read(key: 'jwt_token');
  }

  Future<void> saveAssignedTruck(String truckId) async {
    await _secureStorage.write(key: 'assigned_truck', value: truckId);
  }

  Future<String?> getAssignedTruck() async {
    return await _secureStorage.read(key: 'assigned_truck');
  }

  Future<void> logout() async {
    await _secureStorage.deleteAll();
  }
}