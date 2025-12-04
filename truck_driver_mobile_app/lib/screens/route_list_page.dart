import 'package:flutter/material.dart';
import 'package:truck_driver_mobile_app/screens/navigation_drawer.dart';

class RouteListPage extends StatelessWidget {
  const RouteListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Route lists"),
      ),
      drawer: const MyNavigationDrawer(),
    );
  }
}
