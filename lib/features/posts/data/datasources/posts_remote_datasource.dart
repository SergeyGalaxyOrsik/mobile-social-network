import 'package:dio/dio.dart';

import 'package:mobile_social_network/core/network/api_exception.dart';
import 'package:mobile_social_network/features/posts/data/models/create_post_dto.dart';
import 'package:mobile_social_network/features/posts/data/models/feed_response_dto.dart';
import 'package:mobile_social_network/features/posts/data/models/post_response_dto.dart';

class PostsRemoteDataSource {
  PostsRemoteDataSource(this._dio);

  final Dio _dio;

  Future<FeedResponseDto> getFeed({int? limit, int? offset}) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/posts',
        queryParameters: <String, dynamic>{
          if (limit != null) 'limit': limit,
          if (offset != null) 'offset': offset,
        },
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
