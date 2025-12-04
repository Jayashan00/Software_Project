import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:truck_driver_mobile_app/screens/login_screen.dart';
import 'package:truck_driver_mobile_app/screens/truck_selection_page.dart';
import 'package:truck_driver_mobile_app/screens/home_page.dart';
import 'package:truck_driver_mobile_app/providers/user_provider.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    if (!userProvider.isLoggedIn) {
      return const LoginScreen();
    }

    if (userProvider.truckId == null) {
      return const TruckSelectionPage();
    }

    return const HomePage();
  }
}
