import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';

import 'package:mobile_social_network/core/network/api_exception.dart';
import 'package:mobile_social_network/core/utils/presigned_upload_url.dart';
import 'package:mobile_social_network/features/media/data/datasources/media_remote_datasource.dart';
import 'package:mobile_social_network/features/media/data/models/media_api_models.dart';

class MediaUploadService {
  MediaUploadService({
    required MediaRemoteDataSource api,
    required Dio s3Dio,
    this.presignedUploadOrigin = '',
  }) : _api = api,
       _s3Dio = s3Dio;

  final MediaRemoteDataSource _api;
  final Dio _s3Dio;

  final String presignedUploadOrigin;

  String _effectivePutUrl(String presignedUrl) =>
      resolvePresignedUploadUrl(presignedUrl, presignedUploadOrigin);

  Future<String> uploadLocalFile({
    required String path,
    required String contentType,
    required int fileSizeBytes,
    void Function(double progress)? onProgress,
  }) async {
    final init = await _api.initUpload(
      InitUploadDto(contentType: contentType, fileSizeBytes: fileSizeBytes),
    );

    final mediaId = init.mediaId;
    try {
      if (init.strategy == UploadStrategy.single) {
        final url = init.uploadUrl;
        if (url == null) {
          throw StateError('single upload without uploadUrl');
        }
        final bytes = await File(path).readAsBytes();
        await _s3Dio.put<void>(
          _effectivePutUrl(url),
          data: bytes,
          options: Options(
            headers: <String, dynamic>{Headers.contentTypeHeader: contentType},
            contentType: contentType,
          ),
          onSendProgress: (sent, total) {
            if (total <= 0) return;
            onProgress?.call(sent / total);
          },
        );
        onProgress?.call(1);
        await _api.completeUpload(
          mediaId: mediaId,
          dto: const CompleteUploadDto(),
        );
        return mediaId;
      }

      final uploadId = init.uploadId;
      final partSize = init.partSizeBytes;
      final partCount = init.partCount;
      if (uploadId == null || partSize == null || partCount == null) {
        throw StateError('multipart upload missing metadata');
      }

      final parts = <MultipartPartDto>[];
      var uploadedBytes = 0;

      for (var partNumber = 1; partNumber <= partCount; partNumber++) {
        final offset = (partNumber - 1) * partSize;
        final remaining = fileSizeBytes - offset;
        final length = remaining < partSize ? remaining : partSize;

        final chunk = await _readFileRange(path, offset, length);
        final presign = await _api.presignPart(
          mediaId: mediaId,
          partNumber: partNumber,
        );

        final response = await _s3Dio.put<dynamic>(
          _effectivePutUrl(presign.uploadUrl),
          data: chunk,
          options: Options(contentType: 'application/octet-stream'),
          onSendProgress: (sent, total) {
            final t = total <= 0 ? chunk.length : total;
            final partFrac = sent / t;
            final overall =
                (uploadedBytes + partFrac * chunk.length) / fileSizeBytes;
            onProgress?.call(overall.clamp(0.0, 1.0));
          },
        );

        final etag = response.headers.value('etag');
        if (etag == null || etag.isEmpty) {
          throw ApiException(
            message: 'S3 multipart part $partNumber: missing ETag',
          );
        }
        parts.add(MultipartPartDto(partNumber: partNumber, etag: etag));
        uploadedBytes += chunk.length;
        onProgress?.call((uploadedBytes / fileSizeBytes).clamp(0.0, 1.0));
      }

      parts.sort((a, b) => a.partNumber.compareTo(b.partNumber));

      await _api.completeUpload(
        mediaId: mediaId,
        dto: CompleteUploadDto(parts: parts),
      );
      onProgress?.call(1);
      return mediaId;
    } catch (e) {
      try {
        await _api.abortUpload(mediaId);
      } catch (_) {
        // best effort
      }
      if (e is ApiException) rethrow;
      if (e is DioException) throw ApiException.fromDio(e);
      rethrow;
    }
  }

  static Future<Uint8List> _readFileRange(
    String path,
    int offset,
    int length,
  ) async {
    final raf = await File(path).open();
    try {
      await raf.setPosition(offset);
      final buffer = Uint8List(length);
      final read = await raf.readInto(buffer);
      if (read < length) {
        return Uint8List.sublistView(buffer, 0, read);
      }
      return buffer;
    } finally {
      await raf.close();
    }
  }
}
