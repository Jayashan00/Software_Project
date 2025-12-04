import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:truck_driver_mobile_app/models/TruckAssignmentRequest.dart';
import 'package:truck_driver_mobile_app/screens/navigation_drawer.dart';

import '../models/Truck.dart';
import '../services/truck_service.dart';
import '../providers/user_provider.dart';
import 'home_page.dart';

class TruckSelectionPage extends StatefulWidget {
  const TruckSelectionPage({Key? key}) : super(key: key);

  @override
  State<TruckSelectionPage> createState() => _TruckSelectionPageState();
}

class _TruckSelectionPageState extends State<TruckSelectionPage> {
  final TruckService _truckService = TruckService();

  List<Truck> _availableTrucks = [];
  Truck? _selectedTruck;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchTrucks();
  }

  Future<void> _fetchTrucks() async {
    setState(() => _isLoading = true);
    try {
      final trucks = await _truckService.getAllTrucks();
      if (!mounted) return;
      // Filter for available trucks only
      setState(() => _availableTrucks =
          trucks.where((t) => t.status.toLowerCase() == 'available').toList());
    } catch (e) {
      if (!mounted) return;
      _showErrorSnackBar(
          'Failed to load trucks. Please check your connection.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _assignTruck() async {
    if (_selectedTruck == null) return;
    setState(() => _isLoading = true);

    try {
      final success = await _truckService.assignTruck(
        TruckAssignmentRequest(
            registrationNumber: _selectedTruck!.registrationNumber),
      );
      if (!mounted) return;

      if (success) {
        Provider.of<UserProvider>(context, listen: false)
            .assignTruck(_selectedTruck!.registrationNumber);

        _showSuccessSnackBar(
            '${_selectedTruck!.registrationNumber} assigned successfully!');

        await Future.delayed(const Duration(milliseconds: 800));
        if (!mounted) return;

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
      } else {
        _showErrorSnackBar(
            'Truck assignment failed. It might already be taken.');
      }
    } catch (e) {
      _showErrorSnackBar('An error occurred: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.lightGreen,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Matching dark theme background
      drawer: const MyNavigationDrawer(),
      appBar: AppBar(
        title: const Text('Select Your Truck'),
        centerTitle: true,
        backgroundColor: const Color(0xFF1C1C1C), // Matching dark theme AppBar
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Stack(
        children: [
          _buildContent(),
          if (_isLoading && _availableTrucks.isNotEmpty)
            Container(
              color: Colors.black.withOpacity(0.6),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.lightGreen),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading && _availableTrucks.isEmpty) {
      return const Center(
          child: CircularProgressIndicator(color: Colors.lightGreen));
    }

    if (_availableTrucks.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_off, size: 80, color: Colors.grey[800]),
              const SizedBox(height: 16),
              const Text(
                "No Available Trucks",
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                "Please check back later or contact support if you believe this is an error.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            "Please select your assigned vehicle:",
            style: TextStyle(
                color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: _availableTrucks.length,
              itemBuilder: (context, index) {
                final truck = _availableTrucks[index];
                final isSelected = _selectedTruck == truck;

                return GestureDetector(
                  onTap: () => setState(() => _selectedTruck = truck),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(vertical: 6.0),
                    padding: const EdgeInsets.symmetric(
                        vertical: 16.0, horizontal: 16.0),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2C2C2C), // Matching dark cards
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color:
                            isSelected ? Colors.lightGreen : Colors.grey[800]!,
                        width: isSelected ? 2.5 : 1.0,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.local_shipping_outlined,
                          color:
                              isSelected ? Colors.lightGreen : Colors.white70,
                          size: 32,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            truck.registrationNumber,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        if (isSelected)
                          const Icon(Icons.check_circle,
                              color: Colors.lightGreen)
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed:
                _selectedTruck != null && !_isLoading ? _assignTruck : null,
            icon: const Icon(Icons.check_circle_outline),
            label: const Text("Confirm Selection"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.lightGreen,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              textStyle:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              disabledBackgroundColor: Colors.lightGreen.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }
}
