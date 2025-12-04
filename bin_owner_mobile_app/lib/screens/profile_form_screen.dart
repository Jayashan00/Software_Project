// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

// class ProfileFormScreen extends StatefulWidget {
//   final String userId;

//   const ProfileFormScreen({super.key, required this.userId});

//   @override
//   State<ProfileFormScreen> createState() => _ProfileFormScreenState();
// }

// class _ProfileFormScreenState extends State<ProfileFormScreen> {
//   final _nameController = TextEditingController();
//   final _addressController = TextEditingController();
//   final _mobileController = TextEditingController();
//   bool _isSubmitting = false;

//   Future<void> _submitProfile() async {
//     setState(() => _isSubmitting = true);
//     final response = await http.post(
//       Uri.parse('http://192.168.8.144:8080/api/profile'),
//       headers: {'Content-Type': 'application/json'},
//       body: jsonEncode({
//         'userId': widget.userId,
//         'name': _nameController.text.trim(),
//         'address': _addressController.text.trim(),
//         'mobileNumber': _mobileController.text.trim(),
//       }),
//     );

//     setState(() => _isSubmitting = false);
//     if (response.statusCode == 200) {
//       Navigator.pushReplacementNamed(context, '/home');
//     } else {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text('Profile creation failed')));
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Create Bin Owner Profile")),
//       body: Padding(
//         padding: const EdgeInsets.all(24.0),
//         child: Column(
//           children: [
//             TextField(
//               controller: _nameController,
//               decoration: const InputDecoration(labelText: 'Full Name'),
//             ),
//             TextField(
//               controller: _addressController,
//               decoration: const InputDecoration(labelText: 'Address'),
//             ),
//             TextField(
//               controller: _mobileController,
//               keyboardType: TextInputType.phone,
//               decoration: const InputDecoration(labelText: 'Mobile Number'),
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: _isSubmitting ? null : _submitProfile,
//               child:
//                   _isSubmitting
//                       ? const CircularProgressIndicator()
//                       : const Text("Create Profile"),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

// class ProfileFormScreen extends StatefulWidget {
//   final String userId;

//   const ProfileFormScreen({super.key, required this.userId});

//   @override
//   State<ProfileFormScreen> createState() => _ProfileFormScreenState();
// }

// class _ProfileFormScreenState extends State<ProfileFormScreen> {
//   final _nameController = TextEditingController();
//   final _addressController = TextEditingController();
//   final _mobileController = TextEditingController();
//   bool _isSubmitting = false;

//   // Helper to format UUID string to standard format with dashes
//   String formatUUID(String id) {
//     if (id.length == 32) {
//       return '${id.substring(0, 8)}-'
//           '${id.substring(8, 12)}-'
//           '${id.substring(12, 16)}-'
//           '${id.substring(16, 20)}-'
//           '${id.substring(20)}';
//     }
//     return id; // already formatted UUID
//   }

//   Future<void> _submitProfile() async {
//     setState(() => _isSubmitting = true);

//     final response = await http.post(
//       Uri.parse('http://192.168.8.144:8080/api/profile'),
//       headers: {'Content-Type': 'application/json'},
//       body: jsonEncode({
//         'id': formatUUID(widget.userId), // note key 'id' and formatting
//         'name': _nameController.text.trim(),
//         'address': _addressController.text.trim(),
//         'mobileNumber': _mobileController.text.trim(),
//       }),
//     );

//     setState(() => _isSubmitting = false);

//     if (response.statusCode == 200) {
//       Navigator.pushReplacementNamed(context, '/layout');
//     } else {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(const SnackBar(content: Text('Profile creation failed')));
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Create Bin Owner Profile")),
//       body: Padding(
//         padding: const EdgeInsets.all(24.0),
//         child: Column(
//           children: [
//             TextField(
//               controller: _nameController,
//               decoration: const InputDecoration(labelText: 'Full Name'),
//             ),
//             TextField(
//               controller: _addressController,
//               decoration: const InputDecoration(labelText: 'Address'),
//             ),
//             TextField(
//               controller: _mobileController,
//               keyboardType: TextInputType.phone,
//               decoration: const InputDecoration(labelText: 'Mobile Number'),
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: _isSubmitting ? null : _submitProfile,
//               child:
//                   _isSubmitting
//                       ? const CircularProgressIndicator()
//                       : const Text("Create Profile"),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:bin_owner_mobile_app/theme/colors.dart';
import 'package:bin_owner_mobile_app/config.dart';
class ProfileFormScreen extends StatefulWidget {
  final String userId;

  const ProfileFormScreen({super.key, required this.userId});

  @override
  State<ProfileFormScreen> createState() => _ProfileFormScreenState();
}

class _ProfileFormScreenState extends State<ProfileFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _mobileController = TextEditingController();
  bool _isSubmitting = false;

  String formatUUID(String id) {
    if (id.length == 32) {
      return '${id.substring(0, 8)}-${id.substring(8, 12)}-'
          '${id.substring(12, 16)}-${id.substring(16, 20)}-${id.substring(20)}';
    }
    return id;
  }

  Future<void> _submitProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/admin/users/profile'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id': formatUUID(widget.userId),
          'name': _nameController.text.trim(),
          'address': _addressController.text.trim(),
          'mobileNumber': _mobileController.text.trim(),
        }),
      );

      if (response.statusCode == 200) {
        Navigator.pushReplacementNamed(context, '/layout');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile creation failed. Please try again.'),
          ),
        );
      }
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Complete Your Profile'),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        elevation: 6,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 36),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(theme),
                const SizedBox(height: 40),
                _buildNameField(theme),
                const SizedBox(height: 28),
                _buildAddressField(theme),
                const SizedBox(height: 28),
                _buildMobileField(theme),
                const SizedBox(height: 48),
                _buildSubmitButton(theme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          padding: const EdgeInsets.all(16),
          child: const Icon(
            Icons.person_add_alt_1,
            size: 56,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Let\'s Get Started',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Please provide your details to create your bin owner profile',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary.withOpacity(0.8),
            height: 1.5,
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
    String? helper,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: AppColors.primary),
      helperText: helper,
      helperStyle: TextStyle(
        color: AppColors.textSecondary.withOpacity(0.7),
        fontSize: 12,
        fontWeight: FontWeight.w400,
      ),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: AppColors.primary.withOpacity(0.4)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.8),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.redAccent, width: 2.4),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
    );
  }

  Widget _buildNameField(ThemeData theme) {
    return TextFormField(
      controller: _nameController,
      textCapitalization: TextCapitalization.words,
      decoration: _inputDecoration(
        label: 'Full Name',
        icon: Icons.person_outline,
        helper: 'As per official documents',
      ),
      validator:
          (value) =>
              value == null || value.isEmpty
                  ? 'Please enter your full name'
                  : null,
      style: theme.textTheme.bodyLarge,
    );
  }

  Widget _buildAddressField(ThemeData theme) {
    return TextFormField(
      controller: _addressController,
      maxLines: 3,
      decoration: _inputDecoration(
        label: 'Address',
        icon: Icons.location_on_outlined,
        helper: 'Include street, city, and postal code',
      ),
      validator:
          (value) =>
              value == null || value.isEmpty
                  ? 'Please enter your address'
                  : null,
      style: theme.textTheme.bodyLarge,
    );
  }

  Widget _buildMobileField(ThemeData theme) {
    return TextFormField(
      controller: _mobileController,
      keyboardType: TextInputType.phone,
      decoration: _inputDecoration(
        label: 'Mobile Number',
        icon: Icons.phone_android,
        helper: 'Format: +94 77 123 4567',
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return 'Please enter mobile number';
        if (value.length < 9) return 'Enter a valid mobile number';
        return null;
      },
      style: theme.textTheme.bodyLarge,
    );
  }

  Widget _buildSubmitButton(ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submitProfile,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: theme.textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        child:
            _isSubmitting
                ? const SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 3,
                  ),
                )
                : const Text('Save Profile'),
      ),
    );
  }
}
