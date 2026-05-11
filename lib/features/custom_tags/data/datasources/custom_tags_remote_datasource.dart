import 'package:dio/dio.dart';

import 'package:mobile_social_network/core/network/api_exception.dart';
import 'package:mobile_social_network/features/custom_tags/data/models/custom_tag_api_models.dart';

class CustomTagsRemoteDataSource {
  CustomTagsRemoteDataSource(this._dio);

  final Dio _dio;

  static int _limit(int? limit) => limit == null ? 20 : limit.clamp(1, 100);
  static int _offset(int? offset) => offset == null || offset < 0 ? 0 : offset;

  Future<CustomTagsListResponseDto> list({int? limit, int? offset}) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/custom-tags',
        queryParameters: <String, dynamic>{
          'limit': _limit(limit),
          'offset': _offset(offset),
        },
      );
      return CustomTagsListResponseDto.fromJson(response.data!);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<CustomTagDto> create(String name) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/custom-tags',
        data: <String, dynamic>{'name': name},
      );
      return CustomTagDto.fromJson(response.data!);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<CustomTagDto> update(String tagId, String name) async {
    try {
      final response = await _dio.patch<Map<String, dynamic>>(
        '/custom-tags/$tagId',
        data: <String, dynamic>{'name': name},
      );
      return CustomTagDto.fromJson(response.data!);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<void> delete(String tagId) async {
    try {
      await _dio.delete<void>('/custom-tags/$tagId');
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}
