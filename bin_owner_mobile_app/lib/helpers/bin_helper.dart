import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:bin_owner_mobile_app/theme/colors.dart';

Widget buildEmptyBinMessage() {
  return Center(
    child: Column(
      children: [
        const SizedBox(height: 100),
        Icon(Icons.delete_outline, color: Colors.white54, size: 80),
        const SizedBox(height: 20),
        const Text(
          "No bins found",
          style: TextStyle(color: Colors.white70, fontSize: 20),
        ),
        const SizedBox(height: 10),
        const Text(
          "Please add a bin to monitor its status.",
          style: TextStyle(color: Colors.white38, fontSize: 16),
        ),
      ],
    ),
  );
}
