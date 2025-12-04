// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:flutter/material.dart';

// class VerificationScreen extends StatefulWidget {
//   final String userId;
//   final String email;
//   final String token; // The JWT token you need to pass

//   const VerificationScreen({
//     Key? key,
//     required this.userId,
//     required this.email,
//     required this.token,
//   }) : super(key: key);

//   @override
//   _VerificationScreenState createState() => _VerificationScreenState();
// }

// class _VerificationScreenState extends State<VerificationScreen> {
//   final TextEditingController _codeController = TextEditingController();
//   bool _isLoading = false;

//   Future<void> _verifyCode() async {
//     final code = _codeController.text.trim();
//     if (code.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Please enter the verification code')),
//       );
//       return;
//     }

//     setState(() {
//       _isLoading = true;
//     });

//     final url = Uri.parse(
//       'http://3.1.102.226:8080/api/email-verification/verify',
//     );

//     try {
//       final response = await http.post(
//         url,
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer ${widget.token}', // <-- Bearer token here
//         },
//         // body: jsonEncode({'userId': widget.userId, 'code': code}),
//         body: jsonEncode({'pin': code}),
//       );

//       setState(() {
//         _isLoading = false;
//       });

//       if (response.statusCode == 200) {
//         // Verification successful
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text('Verification successful!')));

//         // Navigate to login or home page
//         Navigator.pushNamedAndRemoveUntil(context, '/layout', (route) => false);
//       } else {
//         final responseData = jsonDecode(response.body);
//         final errorMessage = responseData['message'] ?? 'Verification failed';
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text(errorMessage)));
//       }
//     } catch (e) {
//       setState(() {
//         _isLoading = false;
//       });
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text('Error: $e')));
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Email Verification')),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             Text('Enter the verification code sent to ${widget.email}'),
//             const SizedBox(height: 16),
//             TextField(
//               controller: _codeController,
//               decoration: InputDecoration(
//                 labelText: 'Verification Code',
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             const SizedBox(height: 20),
//             _isLoading
//                 ? CircularProgressIndicator()
//                 : ElevatedButton(onPressed: _verifyCode, child: Text('Verify')),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'dart:convert';
import 'package:bin_owner_mobile_app/config.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bin_owner_mobile_app/theme/colors.dart';

class VerificationScreen extends StatefulWidget {
  final String userId;
  final String email;
  final String token;

  const VerificationScreen({
    Key? key,
    required this.userId,
    required this.email,
    required this.token,
  }) : super(key: key);

  @override
  _VerificationScreenState createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen>
    with TickerProviderStateMixin {
  final TextEditingController _codeController = TextEditingController();
  bool _isVerifying = false;
  bool _isResending = false;
  late AnimationController _animationController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _animationController.forward();
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pulseController.dispose();
    _codeController.dispose();
    super.dispose();
  }

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

  Future<void> _verifyCode() async {
    final code = _codeController.text.trim();

    if (code.isEmpty) {
      _showSnackBar('Please enter the verification code', isError: true);
      _shakeTextField();
      return;
    }

    if (code.length < 6) {
      _showSnackBar('Please enter a complete 6-digit code', isError: true);
      _shakeTextField();
      return;
    }

    setState(() {
      _isVerifying = true;
    });

    final url = Uri.parse('$baseUrl/email-verification/verify');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.token}',
        },
        body: jsonEncode({'pin': code}),
      );

      setState(() {
        _isVerifying = false;
      });

      if (response.statusCode == 200) {
        _showSnackBar('Verification successful!', isError: false);
        await Future.delayed(const Duration(milliseconds: 1500));
        Navigator.pushNamedAndRemoveUntil(context, '/layout', (route) => false);
      } else {
        final responseData = jsonDecode(response.body);
        final errorMessage =
            responseData['message'] ??
            'Invalid verification code. Please try again.';
        _showSnackBar(errorMessage, isError: true);
        _shakeTextField();
      }
    } catch (e) {
      setState(() {
        _isVerifying = false;
      });
      _showSnackBar(
        'Network error. Please check your connection.',
        isError: true,
      );
      _shakeTextField();
    }
  }

  void _shakeTextField() {
    HapticFeedback.lightImpact();
    _codeController.clear();
  }

  Future<void> _resendCode() async {
    setState(() => _isResending = true);

    try {
      await Future.delayed(const Duration(seconds: 2));
      setState(() => _isResending = false);
      _showSnackBar('Verification code sent to ${maskedEmail}', isError: false);
    } catch (e) {
      setState(() => _isResending = false);
      _showSnackBar('Failed to resend code. Please try again.', isError: true);
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
        duration: Duration(milliseconds: isError ? 4000 : 2500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background, // Dark background
      appBar: AppBar(
        title: const Text(
          "Verify Your Email",
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),

                // Animated email icon with dark background
                ScaleTransition(
                  scale: _pulseAnimation,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.2),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(
                            context,
                          ).primaryColor.withOpacity(0.3),
                          blurRadius: 25,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.email_outlined,
                      size: 50,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // Title
                const Text(
                  "Check Your Email",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 16),

                // Subtitle with masked email
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                      height: 1.5,
                    ),
                    children: [
                      const TextSpan(
                        text: "We've sent a 6-digit verification code to\n",
                      ),
                      TextSpan(
                        text: maskedEmail,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // Verification code input - Dark themed
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E), // Dark card background
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey[800]!, width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _codeController,
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
                        fontWeight: FontWeight.w400,
                        letterSpacing: 8,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: Theme.of(context).primaryColor,
                          width: 2,
                        ),
                      ),
                      filled: true,
                      fillColor: const Color(0xFF1E1E1E),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 20,
                      ),
                    ),
                    onChanged: (value) {
                      if (value.length == 6) {
                        FocusScope.of(context).unfocus();
                      }
                    },
                  ),
                ),

                const SizedBox(height: 30),

                // Verify button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isVerifying ? null : _verifyCode,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shadowColor: Theme.of(
                        context,
                      ).primaryColor.withOpacity(0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      disabledBackgroundColor: Colors.grey[700],
                    ),
                    child:
                        _isVerifying
                            ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                            : const Text(
                              "Verify Code",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                  ),
                ),

                const SizedBox(height: 24),

                // Resend code section
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Didn't receive the code? ",
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                    TextButton(
                      onPressed: _isResending ? null : _resendCode,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                      child:
                          _isResending
                              ? SizedBox(
                                width: 12,
                                height: 12,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Theme.of(context).primaryColor,
                                  ),
                                ),
                              )
                              : Text(
                                "Resend",
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Help text - Dark themed
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(
                      0xFF1A237E,
                    ).withOpacity(0.1), // Dark blue background
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF3F51B5).withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.blue[400],
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          "Check your spam folder if you don't see the email",
                          style: TextStyle(
                            color: Colors.blue[300],
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:bin_owner_mobile_app/theme/colors.dart';
// import 'package:bin_owner_mobile_app/enums/verification_type.dart'; // Add this import

// class VerificationScreen extends StatefulWidget {
//   final String userId;
//   final String email;
//   final String token;
//   final VerificationType type; // Add this parameter

//   const VerificationScreen({
//     Key? key,
//     required this.userId,
//     required this.email,
//     required this.token,
//     this.type =
//         VerificationType.emailVerification, // Default to email verification
//   }) : super(key: key);

//   @override
//   _VerificationScreenState createState() => _VerificationScreenState();
// }

// class _VerificationScreenState extends State<VerificationScreen>
//     with TickerProviderStateMixin {
//   final TextEditingController _codeController = TextEditingController();
//   bool _isVerifying = false;
//   bool _isResending = false;
//   late AnimationController _animationController;
//   late AnimationController _pulseController;
//   late Animation<double> _fadeAnimation;
//   late Animation<Offset> _slideAnimation;
//   late Animation<double> _pulseAnimation;

//   @override
//   void initState() {
//     super.initState();

//     _animationController = AnimationController(
//       duration: const Duration(milliseconds: 800),
//       vsync: this,
//     );

//     _pulseController = AnimationController(
//       duration: const Duration(milliseconds: 2000),
//       vsync: this,
//     );

//     _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
//     );

//     _slideAnimation = Tween<Offset>(
//       begin: const Offset(0, 0.3),
//       end: Offset.zero,
//     ).animate(
//       CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
//     );

//     _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
//       CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
//     );

//     _animationController.forward();
//     _pulseController.repeat(reverse: true);
//   }

//   @override
//   void dispose() {
//     _animationController.dispose();
//     _pulseController.dispose();
//     _codeController.dispose();
//     super.dispose();
//   }

//   // Dynamic content based on verification type
//   String get screenTitle {
//     return widget.type == VerificationType.emailVerification
//         ? "Verify Your Email"
//         : "Reset Password";
//   }

//   String get mainTitle {
//     return widget.type == VerificationType.emailVerification
//         ? "Check Your Email"
//         : "Check Your Email";
//   }

//   String get subtitle {
//     return widget.type == VerificationType.emailVerification
//         ? "We've sent a 6-digit verification code to\n"
//         : "We've sent a 6-digit reset code to\n";
//   }

//   IconData get iconData {
//     return widget.type == VerificationType.emailVerification
//         ? Icons.email_outlined
//         : Icons.lock_reset_outlined;
//   }

//   String get buttonText {
//     return widget.type == VerificationType.emailVerification
//         ? "Verify Code"
//         : "Verify Reset Code";
//   }

//   String get maskedEmail {
//     final parts = widget.email.split('@');
//     if (parts.length != 2) return widget.email;

//     final username = parts[0];
//     final domain = parts[1];

//     if (username.length <= 2) return widget.email;

//     final maskedUsername =
//         username[0] +
//         '•' * (username.length - 2) +
//         username[username.length - 1];

//     return '$maskedUsername@$domain';
//   }

//   // Future<void> _verifyCode() async {
//   //   final code = _codeController.text.trim();

//   //   if (code.isEmpty) {
//   //     _showSnackBar('Please enter the verification code', isError: true);
//   //     _shakeTextField();
//   //     return;
//   //   }

//   //   if (code.length < 6) {
//   //     _showSnackBar('Please enter a complete 6-digit code', isError: true);
//   //     _shakeTextField();
//   //     return;
//   //   }

//   //   setState(() {
//   //     _isVerifying = true;
//   //   });

//   //   final url =
//   //       widget.type == VerificationType.emailVerification
//   //           ? Uri.parse('http://10.30.7.90:8080/api/email-verification/verify')
//   //           : Uri.parse('http://10.30.7.90:8080/api/auth/verify-reset-pin');

//   //   try {
//   //     final response = await http.post(
//   //       url,
//   //       headers: {
//   //         'Content-Type': 'application/json',
//   //         'Authorization':
//   //             'Bearer ${widget.token}', // Always use Bearer token now
//   //       },
//   //       body:
//   //           widget.type == VerificationType.emailVerification
//   //               ? jsonEncode({'pin': code})
//   //               : jsonEncode({'pin': code, 'email': widget.email}),
//   //     );

//   //     setState(() {
//   //       _isVerifying = false;
//   //     });

//   //     if (response.statusCode == 200) {
//   //       final data = jsonDecode(response.body);

//   //       if (widget.type == VerificationType.emailVerification) {
//   //         _showSnackBar('Verification successful!', isError: false);
//   //         await Future.delayed(const Duration(milliseconds: 1500));
//   //         Navigator.pushNamedAndRemoveUntil(
//   //           context,
//   //           '/layout',
//   //           (route) => false,
//   //         );
//   //       } else {
//   //         // Password reset verification successful
//   //         if (data['success'] && data['data'] != null) {
//   //           final verifiedToken = data['data']['verifiedToken'];

//   //           _showSnackBar('Code verified successfully!', isError: false);
//   //           await Future.delayed(const Duration(milliseconds: 1500));

//   //           // Navigate to new password screen
//   //           Navigator.pushReplacementNamed(
//   //             context,
//   //             '/reset-password-new',
//   //             arguments: {
//   //               'email': widget.email,
//   //               'verifiedToken': verifiedToken,
//   //             },
//   //           );
//   //         } else {
//   //           _showSnackBar('Verification failed', isError: true);
//   //           _shakeTextField();
//   //         }
//   //       }
//   //     } else {
//   //       final responseData = jsonDecode(response.body);
//   //       final errorMessage =
//   //           responseData['message'] ??
//   //           'Invalid verification code. Please try again.';
//   //       _showSnackBar(errorMessage, isError: true);
//   //       _shakeTextField();
//   //     }
//   //   } catch (e) {
//   //     setState(() {
//   //       _isVerifying = false;
//   //     });
//   //     _showSnackBar(
//   //       'Network error. Please check your connection.',
//   //       isError: true,
//   //     );
//   //     _shakeTextField();
//   //   }
//   // }

//   Future<void> _verifyCode() async {
//     final code = _codeController.text.trim();

//     if (code.isEmpty) {
//       _showSnackBar('Please enter the verification code', isError: true);
//       _shakeTextField();
//       return;
//     }

//     if (code.length < 6) {
//       _showSnackBar('Please enter a complete 6-digit code', isError: true);
//       _shakeTextField();
//       return;
//     }

//     setState(() {
//       _isVerifying = true;
//     });

//     final url =
//         widget.type == VerificationType.emailVerification
//             ? Uri.parse('http://10.30.7.90:8080/api/email-verification/verify')
//             : Uri.parse('http://10.30.7.90:8080/api/auth/verify-reset-pin');

//     try {
//       final response = await http.post(
//         url,
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer ${widget.token}', // Always use Bearer token
//         },
//         body:
//             widget.type == VerificationType.emailVerification
//                 ? jsonEncode({'pin': code})
//                 : jsonEncode({
//                   'pin': code,
//                   'email': widget.email,
//                   // No sessionToken in body anymore
//                 }),
//       );

//       setState(() {
//         _isVerifying = false;
//       });

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);

//         if (widget.type == VerificationType.emailVerification) {
//           _showSnackBar('Verification successful!', isError: false);
//           await Future.delayed(const Duration(milliseconds: 1500));
//           Navigator.pushNamedAndRemoveUntil(
//             context,
//             '/layout',
//             (route) => false,
//           );
//         } else {
//           // Password reset verification successful
//           if (data['success'] && data['data'] != null) {
//             final verifiedToken = data['data']['verifiedToken'];

//             _showSnackBar('Code verified successfully!', isError: false);
//             await Future.delayed(const Duration(milliseconds: 1500));

//             // Navigate to new password screen
//             Navigator.pushReplacementNamed(
//               context,
//               '/reset-password-new',
//               arguments: {
//                 'email': widget.email,
//                 'verifiedToken': verifiedToken,
//               },
//             );
//           } else {
//             _showSnackBar('Verification failed', isError: true);
//             _shakeTextField();
//           }
//         }
//       } else {
//         final responseData = jsonDecode(response.body);
//         final errorMessage =
//             responseData['message'] ??
//             'Invalid verification code. Please try again.';
//         _showSnackBar(errorMessage, isError: true);
//         _shakeTextField();
//       }
//     } catch (e) {
//       setState(() {
//         _isVerifying = false;
//       });
//       _showSnackBar(
//         'Network error. Please check your connection.',
//         isError: true,
//       );
//       _shakeTextField();
//     }
//   }

//   void _shakeTextField() {
//     HapticFeedback.lightImpact();
//     _codeController.clear();
//   }

//   Future<void> _resendCode() async {
//     setState(() => _isResending = true);

//     if (widget.type == VerificationType.passwordReset) {
//       final url = Uri.parse('http://10.30.7.90:8080/api/auth/resend-reset-pin');

//       try {
//         final response = await http.post(
//           url,
//           headers: {
//             'Content-Type': 'application/json',
//             'Authorization': 'Bearer ${widget.token}', // Send token in header
//           },
//           body: jsonEncode({
//             'email': widget.email,
//             // Remove sessionToken from body
//           }),
//         );

//         setState(() => _isResending = false);

//         if (response.statusCode == 200) {
//           _showSnackBar('Reset PIN resent to ${maskedEmail}', isError: false);
//         } else {
//           _showSnackBar(
//             'Failed to resend PIN. Please try again.',
//             isError: true,
//           );
//         }
//       } catch (e) {
//         setState(() => _isResending = false);
//         _showSnackBar('Failed to resend PIN. Please try again.', isError: true);
//       }
//     } else {
//       // Original email verification resend logic remains the same
//       try {
//         await Future.delayed(const Duration(seconds: 2));
//         setState(() => _isResending = false);
//         _showSnackBar(
//           'Verification code sent to ${maskedEmail}',
//           isError: false,
//         );
//       } catch (e) {
//         setState(() => _isResending = false);
//         _showSnackBar(
//           'Failed to resend code. Please try again.',
//           isError: true,
//         );
//       }
//     }
//   }

//   void _showSnackBar(String message, {required bool isError}) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Row(
//           children: [
//             Icon(
//               isError ? Icons.error_outline : Icons.check_circle_outline,
//               color: Colors.white,
//               size: 20,
//             ),
//             const SizedBox(width: 8),
//             Expanded(child: Text(message)),
//           ],
//         ),
//         backgroundColor: isError ? Colors.red[600] : Colors.green[600],
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//         margin: const EdgeInsets.all(16),
//         duration: Duration(milliseconds: isError ? 4000 : 2500),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.background,
//       appBar: AppBar(
//         title: Text(
//           screenTitle, // Dynamic title
//           style: const TextStyle(
//             fontWeight: FontWeight.w600,
//             color: Colors.white,
//           ),
//         ),
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         centerTitle: true,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios, size: 20, color: Colors.white),
//           onPressed: () => Navigator.pop(context),
//         ),
//         systemOverlayStyle: SystemUiOverlayStyle.light,
//       ),
//       body: FadeTransition(
//         opacity: _fadeAnimation,
//         child: SlideTransition(
//           position: _slideAnimation,
//           child: SingleChildScrollView(
//             physics: const BouncingScrollPhysics(),
//             padding: const EdgeInsets.all(24.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 const SizedBox(height: 20),

//                 // Dynamic icon based on type
//                 ScaleTransition(
//                   scale: _pulseAnimation,
//                   child: Container(
//                     width: 100,
//                     height: 100,
//                     decoration: BoxDecoration(
//                       color: Theme.of(context).primaryColor.withOpacity(0.2),
//                       shape: BoxShape.circle,
//                       boxShadow: [
//                         BoxShadow(
//                           color: Theme.of(
//                             context,
//                           ).primaryColor.withOpacity(0.3),
//                           blurRadius: 25,
//                           offset: const Offset(0, 10),
//                         ),
//                       ],
//                     ),
//                     child: Icon(
//                       iconData, // Dynamic icon
//                       size: 50,
//                       color: Theme.of(context).primaryColor,
//                     ),
//                   ),
//                 ),

//                 const SizedBox(height: 30),

//                 // Dynamic title
//                 Text(
//                   mainTitle,
//                   style: const TextStyle(
//                     fontSize: 28,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.white,
//                     letterSpacing: -0.5,
//                   ),
//                   textAlign: TextAlign.center,
//                 ),

//                 const SizedBox(height: 16),

//                 // Dynamic subtitle
//                 RichText(
//                   textAlign: TextAlign.center,
//                   text: TextSpan(
//                     style: const TextStyle(
//                       fontSize: 16,
//                       color: Colors.grey,
//                       height: 1.5,
//                     ),
//                     children: [
//                       TextSpan(text: subtitle),
//                       TextSpan(
//                         text: maskedEmail,
//                         style: TextStyle(
//                           fontWeight: FontWeight.w600,
//                           color: Theme.of(context).primaryColor,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),

//                 const SizedBox(height: 40),

//                 // Rest of your existing UI code remains the same...
//                 Container(
//                   decoration: BoxDecoration(
//                     color: const Color(0xFF1E1E1E),
//                     borderRadius: BorderRadius.circular(16),
//                     border: Border.all(color: Colors.grey[800]!, width: 1),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withOpacity(0.3),
//                         blurRadius: 15,
//                         offset: const Offset(0, 5),
//                       ),
//                     ],
//                   ),
//                   child: TextField(
//                     controller: _codeController,
//                     textAlign: TextAlign.center,
//                     style: const TextStyle(
//                       fontSize: 24,
//                       fontWeight: FontWeight.w600,
//                       letterSpacing: 8,
//                       color: Colors.white,
//                     ),
//                     keyboardType: TextInputType.number,
//                     inputFormatters: [
//                       FilteringTextInputFormatter.digitsOnly,
//                       LengthLimitingTextInputFormatter(6),
//                     ],
//                     decoration: InputDecoration(
//                       hintText: "000000",
//                       hintStyle: TextStyle(
//                         color: Colors.grey[600],
//                         fontWeight: FontWeight.w400,
//                         letterSpacing: 8,
//                       ),
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(16),
//                         borderSide: BorderSide.none,
//                       ),
//                       focusedBorder: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(16),
//                         borderSide: BorderSide(
//                           color: Theme.of(context).primaryColor,
//                           width: 2,
//                         ),
//                       ),
//                       filled: true,
//                       fillColor: const Color(0xFF1E1E1E),
//                       contentPadding: const EdgeInsets.symmetric(
//                         horizontal: 20,
//                         vertical: 20,
//                       ),
//                     ),
//                     onChanged: (value) {
//                       if (value.length == 6) {
//                         FocusScope.of(context).unfocus();
//                       }
//                     },
//                   ),
//                 ),

//                 const SizedBox(height: 30),

//                 // Dynamic verify button
//                 SizedBox(
//                   width: double.infinity,
//                   height: 56,
//                   child: ElevatedButton(
//                     onPressed: _isVerifying ? null : _verifyCode,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Theme.of(context).primaryColor,
//                       foregroundColor: Colors.white,
//                       elevation: 0,
//                       shadowColor: Theme.of(
//                         context,
//                       ).primaryColor.withOpacity(0.3),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(16),
//                       ),
//                       disabledBackgroundColor: Colors.grey[700],
//                     ),
//                     child:
//                         _isVerifying
//                             ? const SizedBox(
//                               width: 24,
//                               height: 24,
//                               child: CircularProgressIndicator(
//                                 strokeWidth: 2,
//                                 valueColor: AlwaysStoppedAnimation<Color>(
//                                   Colors.white,
//                                 ),
//                               ),
//                             )
//                             : Text(
//                               buttonText, // Dynamic button text
//                               style: const TextStyle(
//                                 fontSize: 18,
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             ),
//                   ),
//                 ),

//                 const SizedBox(height: 24),

//                 // Rest of your existing resend code section...
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     const Text(
//                       "Didn't receive the code? ",
//                       style: TextStyle(color: Colors.grey, fontSize: 14),
//                     ),
//                     TextButton(
//                       onPressed: _isResending ? null : _resendCode,
//                       style: TextButton.styleFrom(
//                         padding: const EdgeInsets.symmetric(horizontal: 8),
//                       ),
//                       child:
//                           _isResending
//                               ? SizedBox(
//                                 width: 12,
//                                 height: 12,
//                                 child: CircularProgressIndicator(
//                                   strokeWidth: 2,
//                                   valueColor: AlwaysStoppedAnimation<Color>(
//                                     Theme.of(context).primaryColor,
//                                   ),
//                                 ),
//                               )
//                               : Text(
//                                 "Resend",
//                                 style: TextStyle(
//                                   color: Theme.of(context).primaryColor,
//                                   fontWeight: FontWeight.w600,
//                                   fontSize: 14,
//                                 ),
//                               ),
//                     ),
//                   ],
//                 ),

//                 const SizedBox(height: 20),

//                 Container(
//                   padding: const EdgeInsets.all(16),
//                   decoration: BoxDecoration(
//                     color: const Color(0xFF1A237E).withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(12),
//                     border: Border.all(
//                       color: const Color(0xFF3F51B5).withOpacity(0.3),
//                     ),
//                   ),
//                   child: Row(
//                     children: [
//                       Icon(
//                         Icons.info_outline,
//                         color: Colors.blue[400],
//                         size: 20,
//                       ),
//                       const SizedBox(width: 12),
//                       Expanded(
//                         child: Text(
//                           "Check your spam folder if you don't see the email",
//                           style: TextStyle(
//                             color: Colors.blue[300],
//                             fontSize: 13,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),

//                 const SizedBox(height: 40),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
