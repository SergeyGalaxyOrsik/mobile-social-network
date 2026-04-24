import 'package:dio/dio.dart';

import 'package:mobile_social_network/core/network/api_exception.dart';
import 'package:mobile_social_network/features/chat/data/models/chat_api_models.dart';

class ChatRemoteDataSource {
  ChatRemoteDataSource(this._dio);

  final Dio _dio;

  static int _clampConversationsLimit(int? limit) {
    if (limit == null) return 20;
    return limit.clamp(1, 50);
  }

  static int _clampMessagesLimit(int? limit) {
    if (limit == null) return 30;
    return limit.clamp(1, 100);
  }

  static int _nonNegativeOffset(int? offset) {
    if (offset == null) return 0;
    return offset < 0 ? 0 : offset;
  }

  Future<DirectConversationsResponseDto> listConversations({
    int? limit,
    int? offset,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/chat/direct/conversations',
        queryParameters: <String, dynamic>{
          'limit': _clampConversationsLimit(limit),
          'offset': _nonNegativeOffset(offset),
        },
      );
      return DirectConversationsResponseDto.fromJson(response.data!);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<DirectMessagesResponseDto> listMessages({
    required String peerUserId,
    int? limit,
    int? offset,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        '/chat/direct/messages',
        queryParameters: <String, dynamic>{
          'peer_user_id': peerUserId,
          'limit': _clampMessagesLimit(limit),
          'offset': _nonNegativeOffset(offset),
        },
      );
      final data = response.data;
      if (data is List<dynamic>) {
        return DirectMessagesResponseDto(
          items: data
              .map((e) => DirectMessageDto.fromJson(e as Map<String, dynamic>))
              .where((e) => e.messageId.isNotEmpty)
              .toList(),
        );
      }
      if (data is Map<String, dynamic>) {
        return DirectMessagesResponseDto.fromJson(data);
      }
      return const DirectMessagesResponseDto(items: []);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<DirectMessageDto> sendMessage({
    required String peerUserId,
    String? body,
    List<String> mediaIds = const [],
  }) async {
    try {
      final payload = <String, dynamic>{
        'peer_user_id': peerUserId,
        'media_ids': mediaIds,
      };
      final trimmed = body?.trim();
      if (trimmed != null && trimmed.isNotEmpty) {
        payload['body'] = trimmed;
      }
      final response = await _dio.post<Map<String, dynamic>>(
        '/chat/direct/messages',
        data: payload,
      );
      final data = response.data!;
      final wrapped = data['message'];
      if (wrapped is Map<String, dynamic>) {
        return DirectMessageDto.fromJson(wrapped);
      }
      return DirectMessageDto.fromJson(data);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<void> deleteMessage(String messageId) async {
    try {
      await _dio.delete<void>('/chat/direct/messages/$messageId');
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<DirectBlocksResponseDto> listBlocks() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/chat/direct/blocks',
      );
      return DirectBlocksResponseDto.fromJson(response.data!);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<void> blockUser(String blockedUserId) async {
    try {
      await _dio.post<void>(
        '/chat/direct/blocks',
        data: <String, dynamic>{'blocked_user_id': blockedUserId},
      );
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<void> unblockUser(String blockedUserId) async {
    try {
      await _dio.delete<void>('/chat/direct/blocks/$blockedUserId');
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}
