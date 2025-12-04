import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:truck_driver_mobile_app/models/TruckAssignmentRequest.dart';
import 'package:truck_driver_mobile_app/models/AssignedRoute.dart';
import 'package:truck_driver_mobile_app/screens/navigation_drawer.dart';
import 'package:truck_driver_mobile_app/screens/truck_selection_page.dart';
import 'package:truck_driver_mobile_app/services/route_service.dart';
import 'package:truck_driver_mobile_app/services/truck_service.dart';
import 'package:truck_driver_mobile_app/widgets/custom_google_map.dart';
import '../providers/user_provider.dart';
import 'dart:async';
import 'package:location/location.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  AssignedRoute? _route;
  bool _isLoading = false;
  bool _routeStarted = false;
  bool _routeFinished = false;

  Timer? _locationTimer;
  final Location _location = Location();
  LocationData? _currentLocation;

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
  }

  Future<void> _requestLocationPermission() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) return;
    }

    permissionGranted = await _location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) return;
    }

    // Enable background mode if needed for driving
    // _location.enableBackgroundMode(enable: true);
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: isError ? Colors.red : Colors.lightGreen,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _getAssignedRoute() async {
    setState(() => _isLoading = true);
    try {
      final token = await Provider.of<UserProvider>(context, listen: false).getToken();
      if (token == null) {
        _showSnackBar("Token not found. Please log in again.", isError: true);
        return;
      }
      final route = await RouteService().getAssignedRoute(token);

      setState(() {
        _route = route;
        if (route != null && route.routeStatus == 'IN_PROGRESS') {
             _routeStarted = true;
             _startLocationUpdates(); // Resume tracking if app restarted
        }
        _routeFinished = route?.routeStatus == 'COMPLETED';
      });
    } catch (e) {
      _showSnackBar("Failed to get route: $e", isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _startRoute() async {
    if (_route == null) return;
    setState(() => _isLoading = true);
    final token = await Provider.of<UserProvider>(context, listen: false).getToken();
    if (token == null) return;

    try {
      final success = await RouteService().startRoute(token, _route!.routeId);
      if (success) {
        setState(() => _routeStarted = true);
        _showSnackBar("Route started! Location sharing active.");
        _startLocationUpdates();
      }
    } catch (e) {
      _showSnackBar("Start route failed: $e", isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // LOGIC: Send GPS to Backend every 5 seconds
  void _startLocationUpdates() {
      _locationTimer?.cancel();
      print("🚀 Starting Location Updates...");

      _locationTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
        if (!_routeStarted || _routeFinished) {
          print("🛑 Route not active. Stopping tracker.");
          timer.cancel();
          return;
        }

        try {
          final locData = await _location.getLocation();
          if (mounted) setState(() => _currentLocation = locData);

          final truckId = Provider.of<UserProvider>(context, listen: false).truckId;

          if (truckId != null && locData.latitude != null && locData.longitude != null) {
            print("📡 Sending Location: ${locData.latitude}, ${locData.longitude}");
            await TruckService().updateLocation(truckId, locData.latitude!, locData.longitude!);
          }
        } catch (e) {
          print("Location error: $e");
        }
      });
  }

  Future<void> _markAsCollected(String stopId) async {
    final token = await Provider.of<UserProvider>(context, listen: false).getToken();
    if (token == null) return;

    final binStop = _route?.stops.firstWhere((stop) => stop.id == stopId);
    if (binStop == null) return;

    try {
      final success = await RouteService().markBinCollected(token, _route!.routeId, binStop.binId);
      if (success) {
        setState(() {
          _route!.stops.removeWhere((stop) => stop.id == stopId);
          _showSnackBar("Bin ${binStop.binId} collected.");
        });
      }
    } catch (e) {
      _showSnackBar("Failed to mark bin: $e", isError: true);
    }
  }

  Future<void> _finishRoute() async {
    final token = await Provider.of<UserProvider>(context, listen: false).getToken();
    if (token == null) return;

    try {
      final success = await RouteService().stopRoute(token, _route!.routeId);
      if (success) {
        setState(() => _routeFinished = true);
        _locationTimer?.cancel();
        _showSnackBar("Route finished. Location sharing stopped.");
      }
    } catch (e) {
      _showSnackBar("Failed to finish route: $e", isError: true);
    }
  }

  // Handover logic (Keep existing)
  Future<void> _handOverTruck() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final String? registrationNumber = userProvider.truckId;
    if (registrationNumber == null) return;

    final success = await TruckService().handOverTruck(
      TruckAssignmentRequest(registrationNumber: registrationNumber),
    );
    if (success) {
      userProvider.clearAssignedTruck();
      if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const TruckSelectionPage()));
    }
  }

  @override
  void dispose() {
    _locationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final username = Provider.of<UserProvider>(context).username;
    final truckId = Provider.of<UserProvider>(context).truckId;

    return Scaffold(
      backgroundColor: Colors.black,
      drawer: const MyNavigationDrawer(),
      appBar: AppBar(
        title: const Text("Driver Dashboard", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1C1C1C),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.lightGreen))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Status Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(color: const Color(0xFF2C2C2C), borderRadius: BorderRadius.circular(16)),
                    child: Column(
                      children: [
                        Text("Hello $username", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                        Text("Truck: $truckId", style: const TextStyle(fontSize: 16, color: Colors.white70)),
                        const SizedBox(height: 15),
                        if (_route == null)
                          ElevatedButton(
                            onPressed: _getAssignedRoute,
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.lightGreen),
                            child: const Text("Load My Route", style: TextStyle(color: Colors.white)),
                          ),
                      ],
                    ),
                  ),

                  if (_route != null) ...[
                    const SizedBox(height: 20),
                    if (!_routeStarted)
                      ElevatedButton.icon(
                        icon: const Icon(Icons.play_arrow),
                        label: const Text("START ROUTE"),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green, padding: const EdgeInsets.all(15)),
                        onPressed: _startRoute,
                      ),

                    if (_routeStarted && !_routeFinished)
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        padding: const EdgeInsets.all(10),
                        color: Colors.blue.withOpacity(0.2),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.gps_fixed, color: Colors.blue, size: 16),
                            SizedBox(width: 8),
                            Text("Sharing Live Location...", style: TextStyle(color: Colors.blue)),
                          ],
                        ),
                      ),

                    // Map View
                    SizedBox(
                      height: 300,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: CustomGoogleMap(
                          binStops: _route?.stops ?? [],
                          liveLocation: _currentLocation,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                    const Text("Stops", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),

                    // Bin List
                    ..._route!.stops.map((bin) => Card(
                      color: const Color(0xFF2C2C2C),
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      child: ListTile(
                        leading: const Icon(Icons.delete, color: Colors.white70),
                        title: Text("Bin: ${bin.binId}", style: const TextStyle(color: Colors.white)),
                        subtitle: Text("Lat: ${bin.latitude}, Lng: ${bin.longitude}", style: const TextStyle(color: Colors.grey)),
                        trailing: ElevatedButton(
                          onPressed: () => _markAsCollected(bin.id),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.lightGreen),
                          child: const Text("Done"),
                        ),
                      ),
                    )).toList(),

                    if (_route!.stops.isEmpty && !_routeFinished)
                      Padding(
                        padding: const EdgeInsets.only(top: 20.0),
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.stop),
                          label: const Text("FINISH ROUTE"),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, padding: const EdgeInsets.all(15)),
                          onPressed: _finishRoute,
                        ),
                      ),
                  ]
                ],
              ),
            ),
    );
  }
}