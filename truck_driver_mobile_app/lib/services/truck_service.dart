import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:truck_driver_mobile_app/models/TruckAssignmentRequest.dart';
import '../models/Truck.dart';
import '../models/ApiResponse.dart';
import 'package:truck_driver_mobile_app/config.dart'; // ✅ Import Config

class TruckService {
  // ❌ REMOVED Hardcoded URLs

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // Get JWT token from secure storage
  Future<String?> _getToken() async {
    return await _secureStorage.read(key: 'jwt_token');
  }

  // Fetch list of trucks from backend
  Future<List<Truck>> getAllTrucks() async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('No JWT token found');
    }

    // ✅ Use config baseUrl
    final response = await http.get(
      Uri.parse('$baseUrl/admin/trucks'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

      final apiResponse = ApiResponse<List<Truck>>.fromJson(
        jsonResponse,
        (data) => (data as List).map((e) => Truck.fromJson(e)).toList(),
      );

      if (apiResponse.success) {
        return apiResponse.data
            .where((truck) => truck.status == 'AVAILABLE')
            .toList();
      } else {
        throw Exception('API error: ${apiResponse.message}');
      }
    } else {
      throw Exception(
          'Failed to load trucks. Status code: ${response.statusCode}');
    }
  }

  // Assign a truck
  Future<bool> assignTruck(TruckAssignmentRequest request) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('No JWT token found');
    }

    // ✅ Use config baseUrl
    final response = await http.post(
      Uri.parse('$baseUrl/collector/trucks/assign'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      if (jsonResponse['success'] == true) {
        return true;
      } else {
        throw Exception('Assignment failed: ${jsonResponse['message']}');
      }
    } else {
      throw Exception(
          'Failed to assign truck. Status code: ${response.statusCode}');
    }
  }

  // Handover a truck
  Future<bool> handOverTruck(TruckAssignmentRequest request) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('No JWT token found');
    }

    // ✅ Use config baseUrl
    final response = await http.post(
      Uri.parse('$baseUrl/collector/trucks/handover'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      return jsonResponse['success'] == true;
    } else {
      throw Exception(
          'Failed to hand over truck. Status code: ${response.statusCode}');
    }
  }

  // ✅ Keep this method if you want to support live tracking later
  Future<void> updateLocation(String truckId, double lat, double lng) async {
      // 1. Get the token
      final token = await _getToken();
      if (token == null) {
        print("❌ Cannot update location: No token found");
        return;
      }

      final url = Uri.parse('$baseUrl/admin/trucks/simulate/$truckId?lat=$lat&lng=$lng');

      try {
        // 2. Add the Header!
        final response = await http.post(
          url,
          headers: {
            'Authorization': 'Bearer $token', // <--- THIS WAS MISSING
            'Content-Type': 'application/json',
          },
        );

        if (response.statusCode == 200) {
          print("✅ Location updated: $lat, $lng");
        } else {
          print("❌ Update failed: ${response.statusCode}");
        }
      } catch (e) {
        print("❌ Location update error: $e");
      }
    }
}