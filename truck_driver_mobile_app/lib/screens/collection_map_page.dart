import 'package:flutter/material.dart';
import 'package:truck_driver_mobile_app/models/AssignedRoute.dart';
import 'package:truck_driver_mobile_app/widgets/custom_google_map.dart';
import 'package:truck_driver_mobile_app/screens/navigation_drawer.dart';

class CollectionMapPage extends StatefulWidget {
  const CollectionMapPage({super.key});

  @override
  State<CollectionMapPage> createState() => _CollectionMapPageState();
}

class _CollectionMapPageState extends State<CollectionMapPage> {
  // You can fetch and manage route data here, similar to HomePage
  // For this example, we'll use placeholder data.
  AssignedRoute? _route; // This would be fetched from your service

  @override
  Widget build(BuildContext context) {
    // --- WRAPPED IN A SCAFFOLD TO SUPPORT THE DRAWER ---
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title:
            const Text("Collection Map", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1C1C1C), // Matching your dark theme
        elevation: 0,
      ),
      drawer:
          const MyNavigationDrawer(), // This adds the hamburger icon for your drawer
      // The body is your original Stack layout
      body: Stack(
        children: [
          // --- LAYER 1: The Full-Screen Map ---
          CustomGoogleMap(
            binStops: const [
              // Example BinStops
              // BinStop(id: 1, binId: 101, latitude: 7.2906, longitude: 80.6337),
              // BinStop(id: 2, binId: 102, latitude: 7.2950, longitude: 80.6350),
            ],
            onMarkerTap: (stopId) {
              // Logic to handle marker tap
              print("Map marker tapped: $stopId");
            },
          ),

          // --- LAYER 2: Floating Action Buttons ---
          Positioned(
            top: 16,
            right: 16,
            child: Column(
              children: [
                FloatingActionButton.small(
                  heroTag: 'recenter_fab', // Unique heroTag
                  onPressed: () {
                    // Add logic to recenter the map on the user's location
                  },
                  backgroundColor: const Color(0xFF2C2C2C),
                  child: const Icon(Icons.my_location, color: Colors.white),
                ),
                const SizedBox(height: 10),
                FloatingActionButton.small(
                  heroTag: 'directions_fab', // Unique heroTag
                  onPressed: () {
                    // Add logic to start turn-by-turn navigation in Google Maps
                  },
                  backgroundColor: const Color(0xFF2C2C2C),
                  child: const Icon(Icons.navigation_outlined,
                      color: Colors.white),
                ),
              ],
            ),
          ),

          // --- LAYER 3: The Floating Navigation Panel ---
          DraggableScrollableSheet(
            initialChildSize: 0.2, // Adjusted for better view with AppBar
            minChildSize: 0.2,
            maxChildSize: 0.5,
            builder: (BuildContext context, ScrollController scrollController) {
              return SingleChildScrollView(
                controller: scrollController,
                child: _buildFloatingPanel(),
              );
            },
          ),
        ],
      ),
    );
  }

  // --- UI For the Floating Panel (Unchanged) ---
  Widget _buildFloatingPanel() {
    return Container(
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2C),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
          )
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[700],
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Next Stop",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.delete_outline,
                        color: Colors.lightGreen, size: 32),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Bin ID: 101", // Placeholder
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "Main Street, Kandy", // Placeholder
                            style: TextStyle(color: Colors.white70),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () {
                        // Logic to mark bin as collected
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.lightGreen,
                        foregroundColor: Colors.white,
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(16),
                      ),
                      child: const Icon(Icons.check),
                    )
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
