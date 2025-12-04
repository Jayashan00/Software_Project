class TruckAssignmentRequest {
  final String registrationNumber;

  TruckAssignmentRequest({required this.registrationNumber});

  Map<String, dynamic> toJson() => {
        'registrationNumber': registrationNumber,
      };
}
