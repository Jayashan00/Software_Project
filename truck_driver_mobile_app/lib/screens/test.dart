// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:http/http.dart' as http;
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:provider/provider.dart';
// import 'package:truck_driver_mobile_app/models/Truck.dart';
// import 'package:truck_driver_mobile_app/providers/user_provider.dart';
// import 'package:truck_driver_mobile_app/screens/bin_level_page.dart';
// import 'package:truck_driver_mobile_app/screens/navigation_drawer.dart';

// class HomePage extends StatefulWidget {
//   const HomePage({super.key});

//   @override
//   State<HomePage> createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   Truck? selectedTruck;
//   Set<Marker> _binMarkers = {};
//   late GoogleMapController _controller;
//   Set<Polyline> _polylines = {};
//   int _polylineIdCounter = 1;

//   final CameraPosition _initialPosition = const CameraPosition(
//     target: LatLng(7.252320531045659, 80.59290477694601),
//     zoom: 16,
//   );

//   final List<Map<String, dynamic>> dummyBinStops = [
//     {
//       'id': 'bin1',
//       'position': LatLng(7.2558, 80.5941), // Near Engineering Faculty
//     },
//     {
//       'id': 'bin2',
//       'position': LatLng(7.2575, 80.5982), // Near Arts Theatre
//     },
//     {
//       'id': 'bin3',
//       'position': LatLng(7.2587, 80.5920), // Near Sarasavi Uyana Station
//     },
//     {
//       'id': 'bin4',
//       'position': LatLng(7.2562, 80.5900), // Near Gymnasium
//     },
//   ];

//   final List<Truck> dummyTrucks = [
//     Truck(id: "Truck 1", registrationNumber: 'LZ-1234'),
//     Truck(id: "Truck 2", registrationNumber: 'LZ-5678'),
//     Truck(id: "Truck 3", registrationNumber: 'LY-9101'),
//   ];

//   void _loadBinMarkers() {
//     final markers = dummyBinStops.map((bin) {
//       return Marker(
//         markerId: MarkerId(bin['id']),
//         position: bin['position'],
//         infoWindow: InfoWindow(title: bin['id']),
//         icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
//       );
//     }).toSet();

//     setState(() {
//       _binMarkers = markers;
//     });
//   }

//   List<LatLng> _decodePolyline(String encoded) {
//     List<LatLng> polyline = [];
//     int index = 0, len = encoded.length;
//     int lat = 0, lng = 0;

//     while (index < len) {
//       int b, shift = 0, result = 0;
//       do {
//         b = encoded.codeUnitAt(index++) - 63;
//         result |= (b & 0x1F) << shift;
//         shift += 5;
//       } while (b >= 0x20);
//       int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
//       lat += dlat;

//       shift = 0;
//       result = 0;
//       do {
//         b = encoded.codeUnitAt(index++) - 63;
//         result |= (b & 0x1F) << shift;
//         shift += 5;
//       } while (b >= 0x20);
//       int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
//       lng += dlng;

//       polyline.add(LatLng(lat / 1E5, lng / 1E5));
//     }

//     return polyline;
//   }

//   Future<void> _getOptimizedRoute(Position truckPosition) async {
//     String apiKey = \!;

//     final origin = '${truckPosition.latitude},${truckPosition.longitude}';
//     final waypoints = dummyBinStops.map((bin) {
//       final pos = bin['position'] as LatLng;
//       return '${pos.latitude},${pos.longitude}';
//     }).join('|');

//     final url = Uri.parse(
//       'https://maps.googleapis.com/maps/api/directions/json?origin=$origin&destination=$origin&waypoints=optimize:true|$waypoints&key=$apiKey',
//     );

//     final response = await http.get(url);

//     if (response.statusCode == 200) {
//       final data = json.decode(response.body);
//       if (data['routes'] == null || data['routes'].isEmpty) {
//         print(
//             "No routes found: ${data['status']}, ${data['error_message'] ?? 'No error message'}");
//         return;
//       }

//       final points = data['routes'][0]['overview_polyline']['points'];
//       final polylineCoordinates = _decodePolyline(points);

//       setState(() {
//         _polylines = {
//           Polyline(
//             polylineId: PolylineId("route_${_polylineIdCounter++}"),
//             color: Colors.blue,
//             width: 5,
//             points: polylineCoordinates,
//           ),
//         };
//       });
//     } else {
//       print("Failed to load directions: ${response.body}");
//     }
//   }

//   @override
//   void initState() {
//     super.initState();
//     _loadBinMarkers();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final String? username = Provider.of<UserProvider>(context).username;
//     final String? assignedTruckId = Provider.of<UserProvider>(context).truckId;

//     final Truck? assignedTruck = assignedTruckId == null
//         ? null
//         : dummyTrucks.firstWhere(
//             (truck) => truck.id == assignedTruckId,
//             orElse: () => Truck(id: '', registrationNumber: ''),
//           );

//     return Scaffold(
//       appBar: AppBar(title: const Text("Home Page")),
//       drawer: const MyNavigationDrawer(),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(20),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 "Welcome $username!",
//                 style:
//                     const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
//               ),
//               const SizedBox(height: 35),
//               assignedTruck == null
//                   ? Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const Text("Select Your Truck",
//                             style: TextStyle(
//                                 fontSize: 18, fontWeight: FontWeight.bold)),
//                         DropdownButton<Truck>(
//                           hint: const Text("Select a truck"),
//                           value: selectedTruck,
//                           isExpanded: true,
//                           items: dummyTrucks.map((truck) {
//                             return DropdownMenuItem<Truck>(
//                               value: truck,
//                               child: Text(truck.registrationNumber),
//                             );
//                           }).toList(),
//                           onChanged: (value) {
//                             setState(() {
//                               selectedTruck = value;
//                             });
//                           },
//                         ),
//                         ElevatedButton(
//                           onPressed: selectedTruck == null
//                               ? null
//                               : () {
//                                   Provider.of<UserProvider>(context,
//                                           listen: false)
//                                       .assignTruck(selectedTruck!.id);
//                                   setState(() {});
//                                 },
//                           child: const Text("Assign Truck"),
//                         ),
//                       ],
//                     )
//                   : Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const Text("Assigned Truck",
//                             style: TextStyle(
//                                 fontSize: 18, fontWeight: FontWeight.bold)),
//                         Text(assignedTruck.registrationNumber,
//                             style: const TextStyle(fontSize: 20)),
//                       ],
//                     ),
//               const SizedBox(height: 40),
//               SizedBox(
//                 height: 300,
//                 child: GoogleMap(
//                   initialCameraPosition: _initialPosition,
//                   onMapCreated: (controller) {
//                     _controller = controller;
//                   },
//                   myLocationEnabled: true,
//                   myLocationButtonEnabled: true,
//                   markers: _binMarkers,
//                   polylines: _polylines,
//                 ),
//               ),
//               const SizedBox(height: 30),
//               ElevatedButton(
//                 onPressed: () async {
//                   final position = await Geolocator.getCurrentPosition();
//                   await _getOptimizedRoute(position);
//                 },
//                 child: const Text("Get Optimized Route"),
//               ),
//               const SizedBox(height: 30),
//               ElevatedButton(
//                 onPressed: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => const BinLevelPage(),
//                     ),
//                   );
//                 },
//                 child: const Text("Next location"),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
