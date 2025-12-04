import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:bin_owner_mobile_app/config.dart';
import 'package:bin_owner_mobile_app/theme/colors.dart';

class TruckTrackingScreen extends StatefulWidget {
  final String binId;

  const TruckTrackingScreen({super.key, required this.binId});

  @override
  State<TruckTrackingScreen> createState() => _TruckTrackingScreenState();
}

class _TruckTrackingScreenState extends State<TruckTrackingScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  final _storage = const FlutterSecureStorage();

  Set<Marker> _markers = {};
  LatLng? _truckLocation;
  Timer? _timer;
  bool _isLoading = true;
  String _statusMessage = "Connecting to truck GPS...";

  @override
  void initState() {
    super.initState();
    _startTracking();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTracking() {
    // Initial fetch
    _fetchTruckLocation();
    // Poll every 5 seconds
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _fetchTruckLocation();
    });
  }

  Future<void> _fetchTruckLocation() async {
    try {
      final token = await _storage.read(key: 'jwt_token');
      // This endpoint calls Backend -> TruckInventoryService.getTruckForBin()
      final url = Uri.parse('$baseUrl/admin/trucks/track/bin/${widget.binId}');

      final response = await http.get(url, headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          final truckData = data['data'];

          // Extract Coordinates
          double lat = truckData['latitude'] ?? 0.0;
          double lng = truckData['longitude'] ?? 0.0;
          String plateNum = truckData['registrationNumber'] ?? 'Truck';

          if (lat == 0.0 && lng == 0.0) {
             if (mounted) setState(() => _statusMessage = "Truck assigned, waiting for GPS signal...");
             return;
          }

          // Update Map
          _updateMap(LatLng(lat, lng), plateNum);
        } else {
          if (mounted) setState(() => _statusMessage = "No active truck found for this bin.");
        }
      } else {
         if (mounted) setState(() => _statusMessage = "Searching for route...");
      }
    } catch (e) {
      print("Tracking Error: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _updateMap(LatLng newPos, String plateNum) async {
    if (!mounted) return;

    setState(() {
      _truckLocation = newPos;
      _statusMessage = "Truck is active";

      _markers = {
        Marker(
          markerId: const MarkerId('truck'),
          position: newPos,
          // Green Hue for Truck
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          infoWindow: InfoWindow(title: "Collection Truck", snippet: plateNum),
        ),
      };
    });

    // Move Camera to new position smoothly
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newLatLng(newPos));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Live Tracking", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          // 1. Map Layer
          _truckLocation == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(color: Colors.green),
                      const SizedBox(height: 20),
                      Text(_statusMessage, style: const TextStyle(color: Colors.white54)),
                    ],
                  ),
                )
              : GoogleMap(
                  mapType: MapType.normal,
                  initialCameraPosition: CameraPosition(
                    target: _truckLocation!,
                    zoom: 15,
                  ),
                  markers: _markers,
                  myLocationEnabled: true, // Show user's own location relative to truck
                  onMapCreated: (GoogleMapController controller) {
                    _controller.complete(controller);
                  },
                ),

          // 2. Info Card Layer
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF2C2C2C),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [const BoxShadow(color: Colors.black45, blurRadius: 10)],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.local_shipping, color: Colors.green),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _statusMessage,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          "Update frequency: 5s",
                          style: TextStyle(color: Colors.white54, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}