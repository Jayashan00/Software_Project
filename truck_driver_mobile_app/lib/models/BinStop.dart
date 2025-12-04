class BinStop {
  final String id; // ✅ Changed to String
  final int? stopOrder;
  final String binId;
  final double longitude;
  final double latitude;
  final int paperLevel;
  final int plasticLevel;
  final int glassLevel;
  final String lastEmptiedAt;
  final bool collected;

  BinStop({
    required this.id,
    this.stopOrder,
    required this.binId,
    required this.latitude,
    required this.longitude,
    required this.paperLevel,
    required this.plasticLevel,
    required this.glassLevel,
    required this.lastEmptiedAt,
    this.collected = false,
  });

  factory BinStop.fromJson(Map<String, dynamic> json) {
    return BinStop(
      // ✅ Handle both "id" and "routeStopId" and ensure String
      id: json['routeStopId']?.toString() ?? json['id']?.toString() ?? '',
      stopOrder: json['stopOrder'],
      binId: json['binId']?.toString() ?? '',
      longitude: (json['longitude'] ?? 0).toDouble(),
      latitude: (json['latitude'] ?? 0).toDouble(),
      paperLevel: json['paperLevel'] ?? 0,
      plasticLevel: json['plasticLevel'] ?? 0,
      glassLevel: json['glassLevel'] ?? 0,
      lastEmptiedAt: json['lastEmptiedAt'] ?? '',
      collected: false,
    );
  }

  BinStop copyWith({
    String? id, // ✅ Changed to String
    int? stopOrder,
    String? binId,
    double? longitude,
    double? latitude,
    int? paperLevel,
    int? plasticLevel,
    int? glassLevel,
    String? lastEmptiedAt,
    bool? collected,
  }) {
    return BinStop(
      id: id ?? this.id,
      stopOrder: stopOrder ?? this.stopOrder,
      binId: binId ?? this.binId,
      longitude: longitude ?? this.longitude,
      latitude: latitude ?? this.latitude,
      paperLevel: paperLevel ?? this.paperLevel,
      plasticLevel: plasticLevel ?? this.plasticLevel,
      glassLevel: glassLevel ?? this.glassLevel,
      lastEmptiedAt: lastEmptiedAt ?? this.lastEmptiedAt,
      collected: collected ?? this.collected,
    );
  }
}