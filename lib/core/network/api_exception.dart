import 'package:dio/dio.dart';

import 'package:mobile_social_network/core/api/api_error_body.dart';

class ApiException implements Exception {
  ApiException({this.statusCode, this.body, this.message});

  final int? statusCode;
  final ApiErrorBody? body;
  final String? message;

  String get userMessage => body?.messageAsString.isNotEmpty == true
      ? body!.messageAsString
      : (message ?? 'Network error');

  factory ApiException.fromDio(DioException e) {
    final response = e.response;
    final data = response?.data;
    ApiErrorBody? parsed;
    if (data is Map<String, dynamic>) {
      try {
        parsed = ApiErrorBody.fromJson(data);
      } catch (_) {
        parsed = null;
      }
    }
    return ApiException(
      statusCode: response?.statusCode,
      body: parsed,
      message: e.message,
    );
  }
}
