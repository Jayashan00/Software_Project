import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:truck_driver_mobile_app/models/ApiResponse.dart';
import 'package:truck_driver_mobile_app/models/AssignedRoute.dart';
import 'package:truck_driver_mobile_app/config.dart';

class RouteService {
  Future<AssignedRoute?> getAssignedRoute(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/routes/assigned'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final jsonBody = jsonDecode(response.body);

      // Backend returned: { success: false, data: null }
      if (jsonBody['data'] == null) {
        return null;
      }

      final apiResponse = ApiResponse.fromJson(
        jsonBody,
        (data) => AssignedRoute.fromJson(data),
      );

      return apiResponse.data;
    } else {
      throw Exception('Failed to fetch route');
    }
  }


  // ✅ FIXED: Changed int routeId -> String routeId
  Future<bool> startRoute(String token, String routeId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/routes/$routeId/start'),
      headers: {'Authorization': 'Bearer $token'},
    );
    return response.statusCode == 200;
  }

  // ✅ FIXED: Changed int routeId -> String routeId
  Future<bool> stopRoute(String token, String routeId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/routes/$routeId/stop'),
      headers: {'Authorization': 'Bearer $token'},
    );
    return response.statusCode == 200;
  }

  // ✅ FIXED: Changed int routeId -> String routeId
  Future<bool> markBinCollected(String token, String routeId, String binId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/routes/mark-collected'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'routeId': routeId, 'binId': binId}),
    );
    return response.statusCode == 200;
  }
}