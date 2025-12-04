import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:bin_owner_mobile_app/theme/colors.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:bin_owner_mobile_app/providers/bin_provider.dart';
import 'package:bin_owner_mobile_app/config.dart';

class AddBinScreen extends StatefulWidget {
  const AddBinScreen({super.key});

  @override
  State<AddBinScreen> createState() => _AddBinScreenState();
}

class _AddBinScreenState extends State<AddBinScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _binIdController = TextEditingController();
  final _focusNode = FocusNode();

  bool _isSubmitting = false;
  bool _hasError = false;
  String _errorMessage = '';

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final secureStorage = const FlutterSecureStorage();

  // Design constants
  static const Color backgroundColor = Color(0xFF1E1E1E);
  static const Color surfaceColor = Color.fromARGB(255, 0, 0, 0);
  static const Color cardColor = Color(0xFF2C2C2C);
  static const Color primaryColor = Colors.green;
  static const Color textColor = Colors.white;
  static const Color textSecondaryColor = Color(0xFFB0B0B0);
  static const Color errorColor = Color(0xFFFF5252);
  static const Color successColor = Color(0xFF4CAF50);

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _binIdController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _submitBin() async {
    if (!_formKey.currentState!.validate()) return;

    // Clear any previous errors
    setState(() {
      _isSubmitting = true;
      _hasError = false;
      _errorMessage = '';
    });

    // Add haptic feedback
    HapticFeedback.lightImpact();

    try {
      final token = await secureStorage.read(key: 'jwt_token');
      final binId = _binIdController.text.trim();

      final response = await http
          .put(
            Uri.parse('$baseUrl/bins/$binId/assign'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        // Success feedback
        Provider.of<BinProvider>(context, listen: false).setBinId(binId);
        HapticFeedback.mediumImpact();
        _showSuccessSnackBar('Bin added successfully!');

        // Navigate after a short delay for better UX
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/layout');
        }
      } else {
        _handleError(_getErrorMessage(response.statusCode));
      }
    } catch (e) {
      _handleError(_getNetworkErrorMessage(e));
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _handleError(String message) {
    HapticFeedback.heavyImpact();
    setState(() {
      _hasError = true;
      _errorMessage = message;
    });
    _showErrorSnackBar(message);
  }

  String _getErrorMessage(int statusCode) {
    switch (statusCode) {
      case 400:
        return 'Invalid bin ID format';
      case 401:
        return 'Authentication failed. Please login again';
      case 403:
        return 'You don\'t have permission to add this bin';
      case 404:
        return 'Bin not found. Please check the ID';
      case 409:
        return 'This bin is already assigned to another user';
      case 500:
        return 'Server error. Please try again later';
      default:
        return 'Failed to add bin (Error: $statusCode)';
    }
  }

  String _getNetworkErrorMessage(dynamic error) {
    if (error.toString().contains('TimeoutException')) {
      return 'Connection timeout. Please check your internet';
    }
    return 'Network error. Please check your connection';
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: successColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: errorColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _scanQRCode() {
    // Placeholder for QR code scanning functionality
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('QR Code scanner will be implemented'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 34, 38, 41),

      appBar: _buildAppBar(),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(position: _slideAnimation, child: _buildBody()),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text(
        'Add New Bin',
        style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
      ),

      backgroundColor: const Color.from(
        alpha: 1,
        red: 0.118,
        green: 0.118,
        blue: 0.118,
      ),

      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: textColor),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(),
              const SizedBox(height: 40),
              _buildBinIdCard(),
              const SizedBox(height: 32),
              _buildSubmitButton(),
              const SizedBox(height: 24),
              _buildQRScanOption(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(color: primaryColor.withOpacity(0.3), width: 2),
          ),
          child: const Icon(
            Icons.delete_outline,
            size: 50,
            color: primaryColor,
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Add Your Bin',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Enter your bin ID to start monitoring\nyour waste collection',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: textSecondaryColor,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildBinIdCard() {
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
              Icon(Icons.qr_code_scanner, color: primaryColor, size: 24),
              const SizedBox(width: 12),
              const Text(
                'Bin Identification',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _binIdController,
            focusNode: _focusNode,
            textCapitalization: TextCapitalization.characters,
            style: const TextStyle(
              color: textColor,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              labelText: 'Bin ID',
              hintText: 'Bin001',
              labelStyle: TextStyle(color: textSecondaryColor),
              hintStyle: TextStyle(color: textSecondaryColor.withOpacity(0.6)),
              prefixIcon: Icon(
                Icons.tag,
                color: _focusNode.hasFocus ? primaryColor : textSecondaryColor,
              ),
              suffixIcon:
                  _binIdController.text.isNotEmpty
                      ? IconButton(
                        icon: const Icon(
                          Icons.clear,
                          color: textSecondaryColor,
                        ),
                        onPressed: () {
                          _binIdController.clear();
                          setState(() {});
                        },
                      )
                      : null,
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
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: errorColor, width: 2),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: errorColor, width: 2),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter the Bin ID';
              }
              // if (value.length < 2) {
              //   return 'Bin ID must be at least 2 characters';
              // }
              // if (!RegExp(r'^[A-Z0-9]+$').hasMatch(value)) {
              //   return 'Bin ID can only contain letters and numbers';
              // }
              return null;
            },
            onChanged: (value) {
              if (_hasError) {
                setState(() {
                  _hasError = false;
                  _errorMessage = '';
                });
              }
            },
          ),
          if (_hasError) ...[
            const SizedBox(height: 12),
            Container(
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
                      style: const TextStyle(color: errorColor, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient:
            _isSubmitting
                ? null
                : const LinearGradient(
                  colors: [primaryColor, Color(0xFF66BB6A)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
        color: _isSubmitting ? textSecondaryColor : null,
      ),
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submitBin,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child:
            _isSubmitting
                ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(textColor),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'Adding Bin...',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                  ],
                )
                : const Text(
                  'Add Bin',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
      ),
    );
  }

  Widget _buildQRScanOption() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Divider(color: textSecondaryColor.withOpacity(0.3)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'OR',
                style: TextStyle(
                  color: textSecondaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Expanded(
              child: Divider(color: textSecondaryColor.withOpacity(0.3)),
            ),
          ],
        ),
        const SizedBox(height: 24),
        OutlinedButton.icon(
          onPressed: _scanQRCode,
          icon: const Icon(Icons.qr_code_scanner, color: primaryColor),
          label: const Text(
            'Scan QR Code',
            style: TextStyle(color: primaryColor, fontWeight: FontWeight.w600),
          ),
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: primaryColor.withOpacity(0.5)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          ),
        ),
      ],
    );
  }
}
