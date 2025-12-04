class Bin {
  final String binId;
  final int plasticLevel;
  final int paperLevel;
  final int glassLevel;
  final String? lastEmptiedAt;

  Bin({
    required this.binId,
    required this.plasticLevel,
    required this.paperLevel,
    required this.glassLevel,
    this.lastEmptiedAt,
  });

  factory Bin.fromJson(Map<String, dynamic> json) {
    try {
      print('🔧 Parsing Bin from JSON: $json');

      return Bin(
        binId: json['binId']?.toString() ?? json['id']?.toString() ?? '',
        plasticLevel: _parseLevel(
          json['plasticLevel'] ?? json['plastic_level'],
        ),
        paperLevel: _parseLevel(json['paperLevel'] ?? json['paper_level']),
        glassLevel: _parseLevel(json['glassLevel'] ?? json['glass_level']),
        lastEmptiedAt:
            json['lastEmptiedAt']?.toString() ??
            json['last_emptied_at']?.toString(),
      );
    } catch (e) {
      print('❌ Error parsing Bin JSON: $e');
      print('📋 JSON was: $json');
      rethrow;
    }
  }

  // Helper method to safely parse level values
  static int _parseLevel(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.round();
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    return 0;
  }

  Map<String, dynamic> toJson() {
    return {
      'binId': binId,
      'plasticLevel': plasticLevel,
      'paperLevel': paperLevel,
      'glassLevel': glassLevel,
      'lastEmptiedAt': lastEmptiedAt,
    };
  }

  @override
  String toString() {
    return 'Bin(binId: $binId, plastic: $plasticLevel%, paper: $paperLevel%, glass: $glassLevel%, lastEmptied: $lastEmptiedAt)';
  }
}
