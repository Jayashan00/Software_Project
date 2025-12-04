import 'package:flutter/material.dart';
import 'package:bin_owner_mobile_app/theme/colors.dart';
import 'package:url_launcher/url_launcher.dart'; // Import url_launcher
import 'package:bin_owner_mobile_app/screens/edit_profile_screen.dart';
import 'package:bin_owner_mobile_app/screens/change_password_screen.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = true;
  final _storage = const FlutterSecureStorage();

  // --- ACTIONS ---

  void _editProfile() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => const EditProfileScreen()));
  }

  void _changePassword() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => const ChangePasswordScreen()));
  }

  Future<void> _contactSupport() async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: '+94762881909',
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      _showError('Could not launch dialer');
    }
  }

  Future<void> _emailSupport() async {
    final Uri launchUri = Uri(
      scheme: 'mailto',
      path: 'jayashannawarathna64@gmail.com',
      query: 'subject=EcoRoute Support Request',
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      _showError('Could not launch email client');
    }
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Logout', style: TextStyle(color: Colors.white)),
        content: const Text('Are you sure you want to logout?', style: TextStyle(color: Colors.grey)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await _storage.delete(key: 'jwt_token');
              if (mounted) {
                Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
              }
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.white),
        title: const Text('Settings', style: TextStyle(color: Colors.white)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader('Profile'),
          _buildListTile(title: 'Edit Profile', icon: Icons.person, onTap: _editProfile),
          _buildListTile(title: 'Change Password', icon: Icons.lock, onTap: _changePassword),

          const Divider(height: 40, color: Colors.grey),

          _buildSectionHeader('Preferences'),
          SwitchListTile(
            title: const Text('Notifications', style: TextStyle(color: Colors.white)),
            value: _notificationsEnabled,
            activeColor: AppColors.primary,
            onChanged: (value) => setState(() => _notificationsEnabled = value),
            secondary: Icon(Icons.notifications, color: Colors.grey[400]),
          ),
          SwitchListTile(
            title: const Text('Dark Mode', style: TextStyle(color: Colors.white)),
            value: _darkModeEnabled,
            activeColor: AppColors.primary,
            onChanged: (value) => setState(() => _darkModeEnabled = value),
            secondary: Icon(Icons.dark_mode, color: Colors.grey[400]),
          ),

          const Divider(height: 40, color: Colors.grey),

          _buildSectionHeader('Support'),
          _buildListTile(title: 'Call Support (+9476...)', icon: Icons.phone, onTap: _contactSupport),
          _buildListTile(title: 'Email Support', icon: Icons.email, onTap: _emailSupport),

          const Divider(height: 40, color: Colors.grey),

          _buildSectionHeader('Account'),
          _buildListTile(title: 'Logout', icon: Icons.logout, onTap: _confirmLogout, color: Colors.redAccent),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary)),
    );
  }

  Widget _buildListTile({required String title, required IconData icon, required VoidCallback onTap, Color? color}) {
    return ListTile(
      leading: Icon(icon, color: color ?? Colors.grey[400]),
      title: Text(title, style: TextStyle(color: color ?? Colors.white)),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }
}