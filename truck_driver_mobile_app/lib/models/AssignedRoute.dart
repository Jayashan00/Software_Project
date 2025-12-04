import 'BinStop.dart';

class AssignedRoute {
  final String routeId; // ✅ FIXED: Changed int to String
  final String routeStatus;
  final String? routeStartTime;
  final String? routeEndTime;
  final List<BinStop> stops;

  AssignedRoute({
    required this.routeId,
    required this.routeStatus,
    this.routeStartTime,
    this.routeEndTime,
    required this.stops,
  });

  factory AssignedRoute.fromJson(Map<String, dynamic> json) {
    return AssignedRoute(
      // ✅ FIXED: Convert to String to handle MongoDB ObjectIds safely
      routeId: json['routeId'].toString(),

      // ✅ FIXED: Backend sends 'status', mapping it to routeStatus
      routeStatus: json['status']?.toString() ?? json['routeStatus']?.toString() ?? 'UNKNOWN',

      routeStartTime: json['routeStartTime'],
      routeEndTime: json['routeEndTime'],

      // ✅ FIXED: Backend sends 'binStops', check for both just in case
      stops: ((json['binStops'] ?? json['stops']) as List)
          .map((stopJson) => BinStop.fromJson(stopJson))
          .toList(),
    );
  }
}