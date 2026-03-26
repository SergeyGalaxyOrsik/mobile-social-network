import 'package:dio/dio.dart';

import 'package:mobile_social_network/core/network/api_exception.dart';
import 'package:mobile_social_network/features/media/data/models/media_api_models.dart';

class MediaRemoteDataSource {
  MediaRemoteDataSource(this._dio);

  final Dio _dio;

  Future<InitUploadResponseDto> initUpload(InitUploadDto dto) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/media/upload/init',
        data: dto.toJson(),
      );
      return InitUploadResponseDto.fromJson(response.data!);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<PartPresignResponseDto> presignPart({
    required String mediaId,
    required int partNumber,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/media/$mediaId/multipart/parts/$partNumber/presign',
      );
      return PartPresignResponseDto.fromJson(response.data!);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<void> completeUpload({
    required String mediaId,
    required CompleteUploadDto dto,
  }) async {
    try {
      await _dio.post<void>('/media/$mediaId/complete', data: dto.toJson());
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<void> abortUpload(String mediaId) async {
    try {
      await _dio.delete<void>('/media/$mediaId/upload');
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}
