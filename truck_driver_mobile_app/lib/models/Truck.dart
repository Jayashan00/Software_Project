class Truck {
  final String id;
  final String registrationNumber;
  final String status;

  Truck({
    required this.id,
    required this.registrationNumber,
    required this.status,
  });

  
  factory Truck.fromJson(Map<String, dynamic> json) {
    return Truck(
      id: json['id'].toString(), // Convert to String to be safe
      registrationNumber: json['registrationNumber'],
      status: json['status'] ,
    );
  }

  @override
  String toString() => 'Truck(id: $id, registrationNumber: $registrationNumber), status: $status)';
}
