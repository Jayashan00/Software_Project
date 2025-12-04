import 'package:flutter/material.dart';
import 'package:truck_driver_mobile_app/models/AssignedRoute.dart';

class RouteProvider with ChangeNotifier {
  AssignedRoute? _route;

  AssignedRoute? get route => _route;

  void setRoute(AssignedRoute route) {
    _route = route;
    notifyListeners();
  }

  void clearRoute() {
    _route = null;
    notifyListeners();
  }

  void markStopAsCollected(int id) {
    _route?.stops.removeWhere((stop) => stop.id == id);
    notifyListeners();
  }

  bool get isRouteCompleted => _route?.stops.isEmpty ?? false;
}
