import 'package:dio/dio.dart';

import 'package:mobile_social_network/core/network/api_exception.dart';
import 'package:mobile_social_network/features/notifications/data/models/notifications_api_models.dart';

class NotificationsRemoteDataSource {
  NotificationsRemoteDataSource(this._dio);

  final Dio _dio;

  static int _limit(int? limit) => limit == null ? 20 : limit.clamp(1, 100);
  static int _offset(int? offset) => offset == null || offset < 0 ? 0 : offset;

  Future<NotificationsListResponseDto> list({
    int? limit,
    int? offset,
    bool? unreadOnly,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/users/me/notifications',
        queryParameters: <String, dynamic>{
          'limit': _limit(limit),
          'offset': _offset(offset),
          if (unreadOnly != null) 'unread_only': unreadOnly,
        },
      );
      return NotificationsListResponseDto.fromJson(response.data!);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<void> markAllRead() async {
    try {
      await _dio.patch<void>('/users/me/notifications/read-all');
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<void> markRead(String notificationId) async {
    try {
      await _dio.patch<void>('/users/me/notifications/$notificationId/read');
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<NotificationPreferencesResponseDto> getPreferences() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/users/me/notification-preferences',
      );
      return NotificationPreferencesResponseDto.fromJson(response.data!);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<NotificationPreferencesResponseDto> updatePreferences(
    List<NotificationPreferenceItemDto> items,
  ) async {
    try {
      final response = await _dio.patch<Map<String, dynamic>>(
        '/users/me/notification-preferences',
        data: <String, dynamic>{'items': items.map((e) => e.toJson()).toList()},
      );
      return NotificationPreferencesResponseDto.fromJson(response.data!);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}
