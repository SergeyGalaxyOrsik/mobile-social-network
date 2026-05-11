import 'package:dio/dio.dart';

import 'package:mobile_social_network/core/network/api_exception.dart';
import 'package:mobile_social_network/features/posts/data/models/create_post_dto.dart';
import 'package:mobile_social_network/features/posts/data/models/feed_response_dto.dart';
import 'package:mobile_social_network/features/posts/data/models/post_response_dto.dart';
import 'package:mobile_social_network/features/posts/domain/entities/post_search_sort.dart';
import 'package:mobile_social_network/features/posts/domain/entities/post_visibility.dart';

class PostsRemoteDataSource {
  PostsRemoteDataSource(this._dio);

  final Dio _dio;

  static int _clampFeedLimit(int? limit) {
    if (limit == null) return 20;
    return limit.clamp(1, 100);
  }

  static int _clampFeedOffset(int? offset) {
    if (offset == null) return 0;
    return offset < 0 ? 0 : offset;
  }

  Future<FeedResponseDto> getFeed({int? limit, int? offset}) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/posts',
        queryParameters: <String, dynamic>{
          'limit': _clampFeedLimit(limit),
          'offset': _clampFeedOffset(offset),
        },
      );
      return FeedResponseDto.fromJson(response.data!);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<FeedResponseDto> getPostsByHashtag(
    String hashtag, {
    int? limit,
    int? offset,
  }) async {
    final normalized = hashtag.trim().replaceFirst(RegExp(r'^#+'), '');
    if (normalized.isEmpty) {
      throw ArgumentError.value(hashtag, 'hashtag', 'must not be empty');
    }
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/posts/hashtag/${Uri.encodeComponent(normalized)}',
        queryParameters: <String, dynamic>{
          'limit': _clampFeedLimit(limit),
          'offset': _clampFeedOffset(offset),
        },
      );
      return FeedResponseDto.fromJson(response.data!);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  /// Поиск постов: нечёткое/подстроковое совпадение по `content`, фильтры, сортировка.
  Future<FeedResponseDto> searchPosts({
    String? q,
    PostSearchSort? sort,
    String? authorUserId,
    PostVisibility? visibility,
    int? limit,
    int? offset,
  }) async {
    final params = <String, dynamic>{
      'limit': _clampFeedLimit(limit),
      'offset': _clampFeedOffset(offset),
    };
    final trimmed = q?.trim();
    if (trimmed != null && trimmed.isNotEmpty) {
      params['q'] = trimmed;
    }
    if (sort != null) {
      params['sort'] = sort.toApi();
    }
    final author = authorUserId?.trim();
    if (author != null && author.isNotEmpty) {
      params['author_user_id'] = author;
    }
    if (visibility != null) {
      params['visibility'] = visibility.toJson();
    }
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/posts/search',
        queryParameters: params,
      );
      return FeedResponseDto.fromJson(response.data!);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<PostResponseDto> createPost(CreatePostDto dto) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/posts',
        data: dto.toJson(),
      );
      return PostResponseDto.fromJson(response.data!);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}
