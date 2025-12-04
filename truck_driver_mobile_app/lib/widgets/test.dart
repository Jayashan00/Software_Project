import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  String? _username;
  bool _isLoggedIn = false;

  String? get username => _username;
  bool get isLoggedIn => _isLoggedIn;

  // Called after successful login
  void login(String username) {
    _username = username;
    _isLoggedIn = true;
    notifyListeners();
  }

  // Optional for loading from secure storage later
  void loadUser(String username) {
    _username = username;
    _isLoggedIn = true;
    notifyListeners();
  }

  // Called on logout
  void logout() {
    _username = null;
    _isLoggedIn = false;
    notifyListeners();
  }
}
