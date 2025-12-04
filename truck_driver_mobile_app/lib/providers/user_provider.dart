import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:truck_driver_mobile_app/services/auth_service.dart';

class UserProvider with ChangeNotifier {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  String? _username;
  String? _truckId;
  bool _isLoggedIn = false;
  String? _registrationNumber;
  String? _token;

  String? get username => _username;
  String? get truckId => _truckId;
  bool get isLoggedIn => _isLoggedIn;
  String? get registrationNumber => _registrationNumber;
  String? get token => _token;

  // Login and store token
void login(String username) {
  _username = username;
  _isLoggedIn = true;
  notifyListeners();
}

Future<String?> getToken() async {
  final authService = AuthService();
  return await authService.getToken();
}


  // Assign truck (from selection)
  void assignTruck(String truckId) {
    _truckId = truckId;
    _registrationNumber = truckId;
    notifyListeners();
  }

  // Clear truck when handed over
  void clearAssignedTruck() {
    _truckId = null;
    _registrationNumber = null;
    notifyListeners();
  }

  // Logout and clear storage
  Future<void> logout() async {
    _username = null;
    _truckId = null;
    _registrationNumber = null;
    _isLoggedIn = false;
    _token = null;

    await _storage.delete(key: 'token');
    notifyListeners();
  }

  // Load token from secure storage 
  Future<void> loadToken() async {
    _token = await _storage.read(key: 'token');
    _isLoggedIn = _token != null;
    notifyListeners();
  }
}
