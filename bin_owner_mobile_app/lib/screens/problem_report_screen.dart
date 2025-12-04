import 'package:flutter/material.dart';
import 'package:bin_owner_mobile_app/theme/colors.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:bin_owner_mobile_app/config.dart'; // Import config for baseUrl

class ProblemReportScreen extends StatefulWidget {
  const ProblemReportScreen({super.key});

  @override
  State<ProblemReportScreen> createState() => _ProblemReportScreenState();
}

class _ProblemReportScreenState extends State<ProblemReportScreen> {
  final _binIdController = TextEditingController(); // To enter Bin ID
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  final Map<String, bool> _issues = {
    'Sorting malfunction': false,
    'GPS not working': false,
    'Bin level monitoring not working': false,
    'Lid Broken': false,
  };

  final TextEditingController _messageController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _messageController.dispose();
    _binIdController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    // 1. Validation
    if (_binIdController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the Bin ID')),
      );
      return;
    }

    final selectedIssues = _issues.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();

    final message = _messageController.text.trim();

    if (selectedIssues.isEmpty && message.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an issue or write a message.'),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final token = await _storage.read(key: 'jwt_token');

      // 2. Prepare Data for Backend
      // We combine selected checkboxes into the "requestType" string
      String requestType = selectedIssues.isNotEmpty
          ? selectedIssues.join(", ")
          : "General Issue";

      // We use the message as the description
      String description = message.isNotEmpty
          ? message
          : "Reported issues: $requestType";

      // 3. API Call
      final response = await http.post(
        Uri.parse('$baseUrl/maintenance-requests'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'binId': _binIdController.text.trim(),
          'requestType': requestType,
          'description': description,
          'priority': 'HIGH', // Default to HIGH for user reports
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Report submitted successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        // Clear form
        setState(() {
          _issues.updateAll((key, value) => false);
          _messageController.clear();
          _binIdController.clear();
        });
      } else {
        throw Exception('Failed to submit: ${response.body}');
      }

    } catch (e) {
      print('Error submitting report: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: Could not send report'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView( // Added scroll view to prevent overflow
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Report an issue with your bin:',
              style: TextStyle(fontSize: 18, color: Colors.white70),
            ),
            const SizedBox(height: 20),

            // --- NEW: Bin ID Input ---
            TextField(
              controller: _binIdController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Bin ID (e.g., BIN-002)',
                labelStyle: TextStyle(color: Colors.white60),
                hintText: 'Enter the Bin ID having issues',
                hintStyle: const TextStyle(color: Colors.white30),
                filled: true,
                fillColor: Colors.grey[850],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // -------------------------

            ..._issues.entries.map((entry) {
              return CheckboxListTile(
                title: Text(
                  entry.key,
                  style: const TextStyle(color: Colors.white),
                ),
                value: entry.value,
                onChanged: (bool? value) {
                  setState(() {
                    _issues[entry.key] = value ?? false;
                  });
                },
                activeColor: Colors.green,
                checkColor: Colors.black,
                controlAffinity: ListTileControlAffinity.leading,
              );
            }).toList(),
            const SizedBox(height: 10),
            TextField(
              controller: _messageController,
              maxLines: 3,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Describe any other issue...',
                hintStyle: const TextStyle(color: Colors.white60),
                filled: true,
                fillColor: Colors.grey[850],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _handleSubmit,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child:
                    _isSubmitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                          )
                        : const Text(
                          'Submit Report',
                          style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}