import 'package:dio/dio.dart';

import 'package:mobile_social_network/core/network/api_exception.dart';
import 'package:mobile_social_network/features/draft_posts/data/models/draft_post_api_models.dart';
import 'package:mobile_social_network/features/posts/data/models/post_response_dto.dart';

class DraftPostsRemoteDataSource {
  DraftPostsRemoteDataSource(this._dio);

  final Dio _dio;

  static int _limit(int? limit) => limit == null ? 20 : limit.clamp(1, 100);
  static int _offset(int? offset) => offset == null || offset < 0 ? 0 : offset;

  Future<DraftPostsListResponseDto> list({int? limit, int? offset}) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/draft-posts',
        queryParameters: <String, dynamic>{
          'limit': _limit(limit),
          'offset': _offset(offset),
        },
      );
      return DraftPostsListResponseDto.fromJson(response.data!);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<DraftPostDto> create(UpsertDraftPostDto dto) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/draft-posts',
        data: dto.toJson(),
      );
      return DraftPostDto.fromJson(response.data!);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<DraftPostDto> get(String draftId) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/draft-posts/$draftId',
      );
      return DraftPostDto.fromJson(response.data!);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<DraftPostDto> update(String draftId, UpsertDraftPostDto dto) async {
    try {
      final response = await _dio.patch<Map<String, dynamic>>(
        '/draft-posts/$draftId',
        data: dto.toJson(),
      );
      return DraftPostDto.fromJson(response.data!);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<void> delete(String draftId) async {
    try {
      await _dio.delete<void>('/draft-posts/$draftId');
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<PostResponseDto> publish(String draftId) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/draft-posts/$draftId/publish',
      );
      return PostResponseDto.fromJson(response.data!);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<DraftPostDto> getByCode(String postCode) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/draft-posts/by-code/${Uri.encodeComponent(postCode)}',
      );
      return DraftPostDto.fromJson(response.data!);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}
