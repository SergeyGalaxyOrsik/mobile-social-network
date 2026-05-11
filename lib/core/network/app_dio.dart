import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mobile_social_network/core/config/app_config.dart';
import 'package:mobile_social_network/core/constants/app_constants.dart';

Dio createAppDio({
  required AppConfig appConfig,
  required SharedPreferences preferences,
}) {
  final base = appConfig.apiBaseUrl.trim();
  final normalized = base.endsWith('/')
      ? base.substring(0, base.length - 1)
      : base;

  final dio = Dio(
    BaseOptions(
      baseUrl: normalized,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      headers: <String, dynamic>{
        Headers.contentTypeHeader: Headers.jsonContentType,
        Headers.acceptHeader: Headers.jsonContentType,
      },
      validateStatus: (status) =>
          status != null && status >= 200 && status < 300,
    ),
  );
  final refreshDio = Dio(
    BaseOptions(
      baseUrl: normalized,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      headers: <String, dynamic>{
        Headers.contentTypeHeader: Headers.jsonContentType,
        Headers.acceptHeader: Headers.jsonContentType,
      },
      validateStatus: (status) =>
          status != null && status >= 200 && status < 300,
    ),
  );

  dio.interceptors.add(
    QueuedInterceptorsWrapper(
      onRequest: (options, handler) {
        final token = preferences.getString(AppConstants.accessTokenKey);
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        final request = error.requestOptions;
        if (error.response?.statusCode != 401 ||
            request.extra['authRetry'] == true ||
            request.path == '/auth/refresh') {
          handler.next(error);
          return;
        }

        final currentAccess = preferences.getString(
          AppConstants.accessTokenKey,
        );
        final failedAuthorization = request.headers['Authorization']
            ?.toString();
        if (currentAccess != null &&
            currentAccess.isNotEmpty &&
            failedAuthorization != 'Bearer $currentAccess') {
          request.headers['Authorization'] = 'Bearer $currentAccess';
          request.extra['authRetry'] = true;
          try {
            handler.resolve(await dio.fetch<Object?>(request));
          } on DioException catch (e) {
            handler.next(e);
          }
          return;
        }

        final refreshToken = preferences.getString(
          AppConstants.refreshTokenKey,
        );
        if (refreshToken == null || refreshToken.isEmpty) {
          handler.next(error);
          return;
        }

        try {
          final response = await refreshDio.post<Map<String, dynamic>>(
            '/auth/refresh',
            data: <String, dynamic>{'refreshToken': refreshToken},
          );
          final data = response.data!;
          final nextAccess = data['accessToken'] as String;
          final nextRefresh = data['refreshToken'] as String;
          await preferences.setString(AppConstants.accessTokenKey, nextAccess);
          await preferences.setString(
            AppConstants.refreshTokenKey,
            nextRefresh,
          );
          request.headers['Authorization'] = 'Bearer $nextAccess';
          request.extra['authRetry'] = true;
          handler.resolve(await dio.fetch<Object?>(request));
        } on DioException catch (e) {
          await preferences.remove(AppConstants.accessTokenKey);
          await preferences.remove(AppConstants.refreshTokenKey);
          handler.next(e);
        } catch (_) {
          await preferences.remove(AppConstants.accessTokenKey);
          await preferences.remove(AppConstants.refreshTokenKey);
          handler.next(error);
        }
      },
    ),
  );

  if (kDebugMode) {
    dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (o) => debugPrint(o.toString(), wrapWidth: 1024),
      ),
    );
  }

  return dio;
}
