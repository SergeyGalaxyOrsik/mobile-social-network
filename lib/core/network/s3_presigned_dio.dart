import 'package:dio/dio.dart';

Dio createS3PresignedDio() {
  return Dio(
    BaseOptions(
      connectTimeout: const Duration(minutes: 2),
      sendTimeout: const Duration(minutes: 30),
      receiveTimeout: const Duration(minutes: 2),
      followRedirects: true,
      validateStatus: (status) =>
          status != null && status >= 200 && status < 300,
    ),
  );
}
