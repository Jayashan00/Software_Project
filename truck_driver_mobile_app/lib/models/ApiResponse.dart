class ApiResponse<T> {
  final bool success;
  final String message;
  final T data;
  final DateTime timestamp;

  ApiResponse({
    required this.success,
    required this.message,
    required this.data,
    required this.timestamp,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic) fromJsonT,
  ) {
    return ApiResponse<T>(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: fromJsonT(json['data']),
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}

