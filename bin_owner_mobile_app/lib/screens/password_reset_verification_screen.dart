// lib/screens/password_reset_verification_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:bin_owner_mobile_app/theme/colors.dart';
import 'package:bin_owner_mobile_app/config.dart';

class PasswordResetVerificationScreen extends StatefulWidget {
  final String email;
  final String sessionToken;

  const PasswordResetVerificationScreen({
    Key? key,
    required this.email,
    required this.sessionToken,
  }) : super(key: key);

  @override
  _PasswordResetVerificationScreenState createState() =>
      _PasswordResetVerificationScreenState();
}

class _PasswordResetVerificationScreenState
    extends State<PasswordResetVerificationScreen> {
  final TextEditingController _pinController = TextEditingController();
  bool _isVerifying = false;
  bool _isResending = false;

  String get maskedEmail {
    final parts = widget.email.split('@');
    if (parts.length != 2) return widget.email;
    final username = parts[0];
    final domain = parts[1];
    if (username.length <= 2) return widget.email;
    final maskedUsername =
        username[0] +
        '•' * (username.length - 2) +
        username[username.length - 1];
    return '$maskedUsername@$domain';
  }

  Future<void> _verifyResetPin() async {
    final pin = _pinController.text.trim();

    if (pin.isEmpty) {
      _showSnackBar('Please enter the reset PIN', isError: true);
      return;
    }

    if (pin.length < 6) {
      _showSnackBar('Please enter a complete 6-digit PIN', isError: true);
      return;
    }

    setState(() => _isVerifying = true);

    final url = Uri.parse('$baseUrl/auth/verify-reset-pin');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.sessionToken}',
        },
        body: jsonEncode({'pin': pin, 'email': widget.email}),
      );

      setState(() => _isVerifying = false);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] && data['data'] != null) {
          final verifiedToken = data['data']['verifiedToken'];

          _showSnackBar('PIN verified successfully!', isError: false);
          await Future.delayed(const Duration(milliseconds: 1500));

          Navigator.pushReplacementNamed(
            context,
            '/reset-password-new',
            arguments: {'email': widget.email, 'verifiedToken': verifiedToken},
          );
        } else {
          _showSnackBar('Verification failed', isError: true);
        }
      } else {
        final responseData = jsonDecode(response.body);
        final errorMessage = responseData['message'] ?? 'Invalid PIN';
        _showSnackBar(errorMessage, isError: true);
      }
    } catch (e) {
      setState(() => _isVerifying = false);
      _showSnackBar('Network error. Please try again.', isError: true);
    }
  }

  Future<void> _resendResetPin() async {
    setState(() => _isResending = true);

    final url = Uri.parse('http://10.30.7.90:8080/api/auth/resend-reset-pin');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.sessionToken}',
        },
        body: jsonEncode({'email': widget.email}),
      );

      setState(() => _isResending = false);

      if (response.statusCode == 200) {
        _showSnackBar('Reset PIN resent to $maskedEmail', isError: false);
      } else {
        _showSnackBar('Failed to resend PIN', isError: true);
      }
    } catch (e) {
      setState(() => _isResending = false);
      _showSnackBar('Failed to resend PIN', isError: true);
    }
  }

  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isError ? Colors.red[600] : Colors.green[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          "Reset Password",
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 40),

            // Lock reset icon
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.lock_reset_outlined,
                size: 50,
                color: Theme.of(context).primaryColor,
              ),
            ),

            const SizedBox(height: 30),

            const Text(
              "Enter Reset PIN",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 16),

            Text(
              "We've sent a 6-digit reset PIN to\n$maskedEmail",
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 40),

            // PIN input
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[800]!, width: 1),
              ),
              child: TextField(
                controller: _pinController,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 8,
                  color: Colors.white,
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(6),
                ],
                decoration: InputDecoration(
                  hintText: "000000",
                  hintStyle: TextStyle(
                    color: Colors.grey[600],
                    letterSpacing: 8,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: const Color(0xFF1E1E1E),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 20,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Verify button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isVerifying ? null : _verifyResetPin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child:
                    _isVerifying
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                          "Verify PIN",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
              ),
            ),

            const SizedBox(height: 24),

            // Resend section
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Didn't receive the PIN? ",
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
                TextButton(
                  onPressed: _isResending ? null : _resendResetPin,
                  child:
                      _isResending
                          ? const SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : Text(
                            "Resend",
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }
}
