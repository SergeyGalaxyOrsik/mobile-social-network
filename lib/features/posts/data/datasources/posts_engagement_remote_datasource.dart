import 'package:dio/dio.dart';

import 'package:mobile_social_network/core/network/api_exception.dart';
import 'package:mobile_social_network/features/posts/data/models/comment_api_models.dart';
import 'package:mobile_social_network/features/posts/data/models/post_response_dto.dart';

class PostsEngagementRemoteDataSource {
  PostsEngagementRemoteDataSource(this._dio);

  final Dio _dio;

  Future<RecordPostViewResponseDto> recordPostView(String postId) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/posts/$postId/views',
      );
      return RecordPostViewResponseDto.fromJson(response.data!);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<void> addPostReaction(String postId, CreatePostReactionDto dto) async {
    try {
      await _dio.post<void>('/posts/$postId/reactions', data: dto.toJson());
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<void> removePostReaction(
    String postId, {
    String reactionType = 'like',
  }) async {
    try {
      await _dio.delete<void>(
        '/posts/$postId/reactions',
        queryParameters: <String, dynamic>{'reaction_type': reactionType},
      );
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<PostResponseDto> getPost(String postId) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/posts/$postId');
      return PostResponseDto.fromJson(response.data!);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<CommentsListResponseDto> listComments(
    String postId, {
    int? limit,
    int? offset,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/posts/$postId/comments',
        queryParameters: <String, dynamic>{
          if (limit != null) 'limit': limit,
          if (offset != null) 'offset': offset,
        },
      );
      return CommentsListResponseDto.fromJson(response.data!);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<CommentResponseDto> createComment(
    String postId,
    CreateCommentDto dto,
  ) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/posts/$postId/comments',
        data: dto.toJson(),
      );
      return CommentResponseDto.fromJson(response.data!);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<void> deleteComment(String postId, String commentId) async {
    try {
      await _dio.delete<void>('/posts/$postId/comments/$commentId');
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<void> likeComment(String postId, String commentId) async {
    try {
      await _dio.post<void>('/posts/$postId/comments/$commentId/likes');
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<void> unlikeComment(String postId, String commentId) async {
    try {
      await _dio.delete<void>('/posts/$postId/comments/$commentId/likes');
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}

class RecordPostViewResponseDto {
  const RecordPostViewResponseDto({
    required this.recorded,
    required this.distinctViewers,
  });

  final bool recorded;
  final int distinctViewers;

  factory RecordPostViewResponseDto.fromJson(Map<String, dynamic> json) {
    final rawDistinct = json['distinct_viewers'];
    return RecordPostViewResponseDto(
      recorded: json['recorded'] as bool? ?? false,
      distinctViewers: rawDistinct is num ? rawDistinct.toInt() : 0,
    );
  }
}
