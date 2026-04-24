import 'package:dio/dio.dart';

import 'package:mobile_social_network/core/network/api_exception.dart';
import 'package:mobile_social_network/features/social_users/data/models/social_users_api_models.dart';
import 'package:mobile_social_network/features/social_users/domain/entities/friends_list_sort.dart';

class SocialUsersRemoteDataSource {
  SocialUsersRemoteDataSource(this._dio);

  final Dio _dio;

  static int _clampLimit(int? limit) {
    if (limit == null) return 20;
    return limit.clamp(1, 50);
  }

  static int _clampOffset(int? offset) {
    if (offset == null) return 0;
    return offset < 0 ? 0 : offset;
  }

  Future<FriendsListResponseDto> getFriends({
    String? q,
    FriendsListSort? sort,
    String? usernamePrefix,
    DateTime? friendshipCreatedAfter,
    DateTime? friendshipCreatedBefore,
    int? limit,
    int? offset,
  }) async {
    final params = <String, dynamic>{
      'limit': _clampLimit(limit),
      'offset': _clampOffset(offset),
    };
    final trimmedQ = q?.trim();
    if (trimmedQ != null && trimmedQ.isNotEmpty) {
      params['q'] = trimmedQ;
    }
    if (sort != null) {
      params['sort'] = sort.toApi();
    }
    final prefix = usernamePrefix?.trim();
    if (prefix != null && prefix.isNotEmpty) {
      params['username_prefix'] = prefix;
    }
    if (friendshipCreatedAfter != null) {
      params['friendship_created_after'] =
          friendshipCreatedAfter.toUtc().toIso8601String();
    }
    if (friendshipCreatedBefore != null) {
      params['friendship_created_before'] =
          friendshipCreatedBefore.toUtc().toIso8601String();
    }
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/users/me/friends',
        queryParameters: params,
      );
      return FriendsListResponseDto.fromJson(response.data!);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<UserSearchResponseDto> searchUsers({
    required String q,
    int? limit,
    int? offset,
  }) async {
    final trimmed = q.trim();
    if (trimmed.isEmpty || trimmed.length > 100) {
      throw ArgumentError.value(q, 'q', 'must be 1–100 characters after trim');
    }
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/users/search',
        queryParameters: <String, dynamic>{
          'q': trimmed,
          'limit': _clampLimit(limit),
          'offset': _clampOffset(offset),
        },
      );
      return UserSearchResponseDto.fromJson(response.data!);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<SendFriendRequestResponseDto> sendFriendRequest(
    String targetUserId,
  ) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/users/$targetUserId/friend-requests',
      );
      return SendFriendRequestResponseDto.fromJson(response.data!);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<FriendRequestsListResponseDto> getIncomingFriendRequests({
    int? limit,
    int? offset,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/users/me/friend-requests/incoming',
        queryParameters: <String, dynamic>{
          'limit': _clampLimit(limit),
          'offset': _clampOffset(offset),
        },
      );
      return FriendRequestsListResponseDto.fromJson(response.data!);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<FriendRequestsListResponseDto> getOutgoingFriendRequests({
    int? limit,
    int? offset,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/users/me/friend-requests/outgoing',
        queryParameters: <String, dynamic>{
          'limit': _clampLimit(limit),
          'offset': _clampOffset(offset),
        },
      );
      return FriendRequestsListResponseDto.fromJson(response.data!);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<void> acceptFriendRequest(String requestId) async {
    try {
      await _dio.post<void>(
        '/users/me/friend-requests/$requestId/accept',
      );
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<void> declineFriendRequest(String requestId) async {
    try {
      await _dio.post<void>(
        '/users/me/friend-requests/$requestId/decline',
      );
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<void> cancelOutgoingFriendRequest(String requestId) async {
    try {
      await _dio.delete<void>(
        '/users/me/friend-requests/$requestId',
      );
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<ProfileResponseDto> getUserProfile(
    String profileUserId, {
    int? limit,
    int? offset,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/users/$profileUserId/profile',
        queryParameters: <String, dynamic>{
          'limit': _clampLimit(limit),
          'offset': _clampOffset(offset),
        },
      );
      return ProfileResponseDto.fromJson(response.data!);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<ReportUserResponseDto> reportUser(
    String reportedUserId,
    ReportUserRequestDto body,
  ) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/users/$reportedUserId/reports',
        data: body.toJson(),
      );
      return ReportUserResponseDto.fromJson(response.data!);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}
