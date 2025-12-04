import 'package:bin_owner_mobile_app/services/bin_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/bin.dart';
import 'package:bin_owner_mobile_app/config.dart';
import 'package:bin_owner_mobile_app/screens/truck_tracking_screen.dart'; // ✅ Added Import

class BinLevelScreen extends StatefulWidget {
  const BinLevelScreen({super.key});

  @override
  State<BinLevelScreen> createState() => _BinLevelScreenState();
}

class _BinLevelScreenState extends State<BinLevelScreen> {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final String _baseURL = '$baseUrl';
  final PageController _pageController = PageController(viewportFraction: 0.85);

  List<Bin> _bins = [];
  String? _selectedBinId;
  bool _isLoading = true;
  String _errorMessage = '';
  int _currentPageIndex = 0;

  // UI Constants
  static const Color backgroundColor = Color(0xFF1E1E1E); // Adjusted slightly for better contrast
  static const Color surfaceColor = Color(0xFF121212);
  static const Color cardColor = Color(0xFF2C2C2C);
  static const Color primaryColor = Colors.green;
  static const Color textColor = Colors.white;
  static const Color textSecondaryColor = Color(0xFFB0B0B0);
  static const Color errorColor = Color(0xFFFF5252);

  @override
  void initState() {
    super.initState();
    _fetchBins();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _fetchBins() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final token = await _storage.read(key: 'jwt_token');
      if (token == null) {
        setState(() {
          _errorMessage = 'No authentication token found.';
          _isLoading = false;
        });
        return;
      }

      final binService = BinService();
      // Optional: Check connection first if needed, or rely on fetch error handling
      // final isConnected = await binService.testConnection(_baseURL);

      final fetchedBins = await binService.fetchBins(
        baseURL: _baseURL,
        token: token,
      );

      final List<Bin> binStatuses = [];

      for (var bin in fetchedBins) {
        try {
          final status = await binService.getBinStatus(
            baseURL: _baseURL,
            token: token,
            binId: bin.binId,
          );
          binStatuses.add(status);
        } catch (_) {
          binStatuses.add(bin); // Fallback
        }
      }

      setState(() {
        _bins = binStatuses;
        // Keep selected bin if it still exists, otherwise select first
        if (_selectedBinId == null || !_bins.any((b) => b.binId == _selectedBinId)) {
             _selectedBinId = _bins.isNotEmpty ? _bins[0].binId : null;
        }
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error fetching bins: ${e.toString()}';
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _navigateToAddBin() {
    Navigator.pushNamed(context, '/addBin');
  }

  Widget _buildErrorBanner() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: errorColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: errorColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: errorColor, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _errorMessage,
              style: TextStyle(color: errorColor, fontSize: 14),
            ),
          ),
          IconButton(
            icon: Icon(Icons.close, color: errorColor),
            onPressed: () => setState(() => _errorMessage = ''),
          ),
        ],
      ),
    );
  }

  Widget _buildBinDropdown() {
    final binColors = [
      const Color(0xFFFFB1B1),
      const Color(0xFFB1D7FF),
      const Color(0xFFFFF3B1),
      const Color(0xFFB1FFB1),
    ];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.delete_outline, color: primaryColor, size: 24),
              const SizedBox(width: 12),
              const Text(
                'Pick a Bin',
                style: TextStyle(
                  color: textColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          DropdownButtonFormField<String>(
            value: _selectedBinId,
            onChanged: (value) {
              setState(() {
                _selectedBinId = value;
                _pageController.jumpToPage(0);
              });
            },
            decoration: InputDecoration(
              hintText: 'Select a bin',
              hintStyle: TextStyle(
                color: textSecondaryColor.withOpacity(0.6),
                fontFamily: 'ComicNeue',
              ),
              filled: true,
              fillColor: surfaceColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: cardColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: cardColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: primaryColor, width: 2),
              ),
            ),
            dropdownColor: cardColor,
            items: _bins.asMap().entries.map((entry) {
                  final index = entry.key;
                  final bin = entry.value;
                  return DropdownMenuItem<String>(
                    value: bin.binId,
                    child: Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: binColors[index % binColors.length],
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Bin ${bin.binId}',
                          style: const TextStyle(
                            color: textColor,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
            icon: Icon(Icons.arrow_drop_down_circle, color: primaryColor),
          ),
        ],
      ),
    );
  }

  Widget _buildWasteLevelPager(Bin bin) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.recycling, color: primaryColor, size: 24),
              const SizedBox(width: 12),
              const Text(
                'Waste Levels',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                  fontFamily: 'ComicNeue',
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 260,
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPageIndex = index;
                });
              },
              children: [
                _WasteTypeCard(
                  type: 'Plastic',
                  level: bin.plasticLevel,
                  color: const Color(0xFF2196F3),
                  icon: Icons.local_drink,
                ),
                _WasteTypeCard(
                  type: 'Paper',
                  level: bin.paperLevel,
                  color: const Color(0xFFFFCA28),
                  icon: Icons.description,
                ),
                _WasteTypeCard(
                  type: 'Glass',
                  level: bin.glassLevel,
                  color: const Color(0xFF4CAF50),
                  icon: Icons.local_bar,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, _buildPageIndicator),
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator(int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: _currentPageIndex == index ? 14 : 8,
      height: _currentPageIndex == index ? 14 : 8,
      decoration: BoxDecoration(
        color: _currentPageIndex == index ? primaryColor : textSecondaryColor,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildHealthStatus() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.favorite, color: primaryColor, size: 40),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Healthy Bin!',
                style: TextStyle(
                  color: textColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'ComicNeue',
                ),
              ),
              Text(
                'All systems happy!',
                style: TextStyle(
                  color: textSecondaryColor,
                  fontSize: 14,
                  fontFamily: 'ComicNeue',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddBin,
        backgroundColor: primaryColor,
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add_circle, size: 30),
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Loading your bins...',
                    style: TextStyle(
                      color: textSecondaryColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              color: primaryColor,
              backgroundColor: surfaceColor,
              onRefresh: _fetchBins,
              child: _bins.isEmpty && _errorMessage.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: primaryColor.withOpacity(0.1),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: primaryColor.withOpacity(0.3),
                                width: 2,
                              ),
                            ),
                            child: const Icon(
                              Icons.delete_outline,
                              size: 50,
                              color: primaryColor,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No bins found. Add a bin!',
                            style: TextStyle(
                              color: textColor,
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          Container(
                            height: 56,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              gradient: const LinearGradient(
                                colors: [primaryColor, Color(0xFF66BB6A)],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                            ),
                            child: ElevatedButton(
                              onPressed: _navigateToAddBin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: const Text(
                                'Add a Bin',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: textColor,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_errorMessage.isNotEmpty) _buildErrorBanner(),
                          const SizedBox(height: 16),
                          _buildBinDropdown(),
                          const SizedBox(height: 24),

                          if (_selectedBinId != null)
                            _buildWasteLevelPager(
                              _bins.firstWhere(
                                (bin) => bin.binId == _selectedBinId,
                              ),
                            ),

                          // ✅ TRACKING BUTTON
                          if (_selectedBinId != null) ...[
                            const SizedBox(height: 24),
                            Container(
                              width: double.infinity,
                              height: 54,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                color: Colors.blueAccent.withOpacity(0.15),
                                border: Border.all(color: Colors.blueAccent.withOpacity(0.5)),
                              ),
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.local_shipping, color: Colors.blueAccent),
                                label: const Text("Track Collection Truck", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => TruckTrackingScreen(binId: _selectedBinId!),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],

                          const SizedBox(height: 32),
                          if (_bins.isNotEmpty) _buildHealthStatus(),
                          const SizedBox(height: 40), // Bottom padding
                        ],
                      ),
                    ),
            ),
    );
  }
}

class _WasteTypeCard extends StatelessWidget {
  final String type;
  final int level;
  final Color color;
  final IconData icon;

  const _WasteTypeCard({
    required this.type,
    required this.level,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _BinLevelScreenState.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 8),
              Text(
                type,
                style: const TextStyle(
                  fontSize: 20,
                  color: _BinLevelScreenState.textColor,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'ComicNeue',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 100,
                height: 100,
                child: CircularProgressIndicator(
                  value: level / 100,
                  strokeWidth: 12,
                  backgroundColor: _BinLevelScreenState.textSecondaryColor
                      .withOpacity(0.3),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
              Text(
                '$level%',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: color,
                  fontFamily: 'ComicNeue',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            level >= 80
                ? 'Super Full!'
                : level >= 50
                ? 'Halfway There!'
                : 'Plenty of Room!',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 14,
              fontFamily: 'ComicNeue',
            ),
          ),
        ],
      ),
    );
  }
}