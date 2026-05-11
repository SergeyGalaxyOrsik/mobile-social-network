import 'package:dio/dio.dart';

import 'package:mobile_social_network/core/network/api_exception.dart';
import 'package:mobile_social_network/features/saved_posts/data/models/saved_post_api_models.dart';

class SavedPostsRemoteDataSource {
  SavedPostsRemoteDataSource(this._dio);

  final Dio _dio;

  static int _limit(int? limit) => limit == null ? 20 : limit.clamp(1, 100);
  static int _offset(int? offset) => offset == null || offset < 0 ? 0 : offset;

  Future<SavedPostsListResponseDto> list({int? limit, int? offset}) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/saved-posts',
        queryParameters: <String, dynamic>{
          'limit': _limit(limit),
          'offset': _offset(offset),
        },
      );
      return SavedPostsListResponseDto.fromJson(response.data!);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<void> save(String postId) async {
    try {
      await _dio.post<void>('/saved-posts/$postId');
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<void> remove(String postId) async {
    try {
      await _dio.delete<void>('/saved-posts/$postId');
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<void> addTag(String postId, String tagId) async {
    try {
      await _dio.post<void>('/saved-posts/$postId/tags/$tagId');
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<void> removeTag(String postId, String tagId) async {
    try {
      await _dio.delete<void>('/saved-posts/$postId/tags/$tagId');
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}
