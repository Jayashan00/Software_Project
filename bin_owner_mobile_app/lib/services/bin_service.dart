import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/bin.dart';

class BinService {
  Future<List<Bin>> fetchBins({
    required String baseURL,
    required String token,
  }) async {
    // NEW (Correct)
    final url = '$baseURL/bins/fetch';
    print('🔍 Fetching bins from: $url');

    try {
      final response = await http
          .get(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 10)); // Add timeout

      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = json.decode(response.body);

        // Debug: Print the actual response structure
        print('Response structure: ${body.keys}');

        if (body['success'] == true && body['data'] != null) {
          final List<dynamic> data = body['data'];
          print('Found ${data.length} bins');

          // Debug: Print first bin structure if available
          if (data.isNotEmpty) {
            print('First bin structure: ${data[0].keys}');
          }

          return data.map((binData) => Bin.fromJson(binData)).toList();
        } else {
          print('API response success false or no data');
          print('Success: ${body['success']}');
          print('Data: ${body['data']}');
          throw Exception('API response success false or no data');
        }
      } else {
        print('HTTP Error: ${response.statusCode}');
        print('Error body: ${response.body}');
        throw Exception(
          'Failed to load bins: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('Exception in fetchBins: $e');
      throw Exception('Error fetching bins: $e');
    }
  }

  // To get status for a specific bin
  Future<Bin> getBinStatus({
    required String baseURL,
    required String token,
    required String binId,
  }) async {
    // NEW (Correct)
    final url = '$baseURL/bin/status/fetch/$binId';
    print('Fetching bin status from: $url');

    try {
      final response = await http
          .get(
            Uri.parse(url),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 10)); // Add timeout

      print('Bin Status Response: ${response.statusCode}');
      print('Bin Status Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);

        // Handle different response structures
        dynamic binData;
        if (responseBody is Map<String, dynamic>) {
          if (responseBody.containsKey('data')) {
            binData = responseBody['data'];
          } else if (responseBody.containsKey('success') &&
              responseBody['success'] == true) {
            binData = responseBody['data'];
          } else {
            // Maybe the response is the bin data directly
            binData = responseBody;
          }
        } else {
          binData = responseBody;
        }

        print('Bin data structure: ${binData.runtimeType}');
        if (binData is Map) {
          print('Bin data keys: ${binData.keys}');
        }

        return Bin.fromJson(binData);
      } else {
        print('Bin Status HTTP Error: ${response.statusCode}');
        print('Error body: ${response.body}');
        throw Exception(
          'Failed to fetch bin status: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('Exception in getBinStatus: $e');
      throw Exception('Error fetching bin status: $e');
    }
  }

  // Helper method to test connectivity
  Future<bool> testConnection(String baseURL) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseURL/api/health'), // or any simple endpoint
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 5));

      print('Connection test: ${response.statusCode}');
      return response.statusCode < 500;
    } catch (e) {
      print('Connection test failed: $e');
      return false;
    }
  }
}
