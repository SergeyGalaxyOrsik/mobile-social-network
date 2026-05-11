import 'package:dio/dio.dart';

import 'package:mobile_social_network/core/network/api_exception.dart';
import 'package:mobile_social_network/features/user_settings/data/models/user_preferences_dto.dart';

class UserSettingsRemoteDataSource {
  UserSettingsRemoteDataSource(this._dio);

  final Dio _dio;

  Future<UserPreferencesDto> getSettings() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/user/settings');
      return UserPreferencesDto.fromJson(response.data!);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<UserPreferencesDto> updateSettings(Map<String, dynamic> patch) async {
    try {
      final response = await _dio.patch<Map<String, dynamic>>(
        '/user/settings',
        data: patch,
      );
      return UserPreferencesDto.fromJson(response.data!);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}
