import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapService {
  // Use your actual API Key here
  static const String _apiKey = 'AIzaSyD4L8c1CL6n2Re-5DgDaXLPjAT83nheI58';
  static const String _directionsUrl = 'https://maps.googleapis.com/maps/api/directions/json';

  Future<List<LatLng>> getRouteCoordinates({
    required LatLng origin,
    required List<LatLng> destinations,
  }) async {
    if (destinations.isEmpty) return [];

    // Google Directions API allows waypoints.
    // We treat the LAST bin as the destination, and others as intermediate waypoints.
    LatLng finalDestination = destinations.last;
    List<LatLng> waypoints = destinations.sublist(0, destinations.length - 1);

    String originStr = '${origin.latitude},${origin.longitude}';
    String destStr = '${finalDestination.latitude},${finalDestination.longitude}';

    // Format waypoints: "lat,lng|lat,lng"
    String waypointsStr = waypoints
        .map((w) => '${w.latitude},${w.longitude}')
        .join('|');

    String url = '$_directionsUrl?origin=$originStr&destination=$destStr&key=$_apiKey&mode=driving';
    if (waypointsStr.isNotEmpty) {
      url += '&waypoints=optimize:true|$waypointsStr';
    }

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);

        if (json['status'] == 'OK') {
          // Decode the encoded polyline string
          final points = PolylinePoints().decodePolyline(json['routes'][0]['overview_polyline']['points']);
          return points.map((e) => LatLng(e.latitude, e.longitude)).toList();
        } else {
          print("⚠️ Map API Error: ${json['status']}");
          return [];
        }
      }
      return [];
    } catch (e) {
      print("⚠️ Map Exception: $e");
      return [];
    }
  }
}