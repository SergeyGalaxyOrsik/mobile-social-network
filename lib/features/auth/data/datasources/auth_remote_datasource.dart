import 'package:dio/dio.dart';

import 'package:mobile_social_network/core/network/api_exception.dart';
import 'package:mobile_social_network/features/auth/data/models/auth_tokens_response_dto.dart';
import 'package:mobile_social_network/features/auth/data/models/auth_user_view_dto.dart';
import 'package:mobile_social_network/features/auth/data/models/login_dto.dart';
import 'package:mobile_social_network/features/auth/data/models/register_dto.dart';

class AuthRemoteDataSource {
  AuthRemoteDataSource(this._dio);

  final Dio _dio;

  Future<void> health() async {
    await _dio.get<Object?>('/');
  }

  Future<AuthTokensResponseDto> register(RegisterDto dto) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/auth/register',
        data: dto.toJson(),
      );
      return AuthTokensResponseDto.fromJson(response.data!);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<AuthTokensResponseDto> login(LoginDto dto) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/auth/login',
        data: dto.toJson(),
      );
      return AuthTokensResponseDto.fromJson(response.data!);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<AuthUserViewDto> me() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/auth/me');
      return AuthUserViewDto.fromJson(response.data!);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  /// Регистрация FCM-токена после входа (`docs/API_PUSH_EVENTS.md`).
  Future<void> registerPushToken(
    String fcmToken, {
    String? platform,
  }) async {
    try {
      await _dio.post<void>(
        '/users/me/push-tokens',
        data: <String, dynamic>{
          'fcm_token': fcmToken,
          if (platform != null && platform.isNotEmpty) 'platform': platform,
        },
      );
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  /// Снятие токена при выходе или отказе от пушей.
  Future<void> deletePushToken(String fcmToken) async {
    try {
      await _dio.delete<void>(
        '/users/me/push-tokens',
        data: <String, dynamic>{'fcm_token': fcmToken},
      );
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}
