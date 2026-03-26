class ApiErrorBody {
  const ApiErrorBody({
    required this.statusCode,
    required this.error,
    this.message,
  });

  final int statusCode;
  final String error;
  final dynamic message;

  factory ApiErrorBody.fromJson(Map<String, dynamic> json) {
    return ApiErrorBody(
      statusCode: json['statusCode'] as int? ?? 0,
      error: json['error'] as String? ?? '',
      message: json['message'],
    );
  }

  String get messageAsString {
    final m = message;
    if (m == null) return '';
    if (m is String) return m;
    if (m is List) return m.map((e) => e.toString()).join('\n');
    return m.toString();
  }
}
