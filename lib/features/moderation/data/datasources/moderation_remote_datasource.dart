import 'package:dio/dio.dart';

import 'package:mobile_social_network/core/network/api_exception.dart';

class ModerationReportsResponseDto {
  const ModerationReportsResponseDto({
    required this.items,
    required this.total,
  });

  final List<Map<String, dynamic>> items;
  final int total;

  factory ModerationReportsResponseDto.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List<dynamic>? ?? const [];
    final rawTotal = json['total'];
    return ModerationReportsResponseDto(
      items: rawItems
          .map((e) => Map<String, dynamic>.from(e as Map<String, dynamic>))
          .toList(),
      total: rawTotal is num ? rawTotal.toInt() : rawItems.length,
    );
  }
}

class ModerationRemoteDataSource {
  ModerationRemoteDataSource(this._dio);

  final Dio _dio;

  static int _limit(int? limit) => limit == null ? 20 : limit.clamp(1, 50);
  static int _offset(int? offset) => offset == null || offset < 0 ? 0 : offset;

  Future<ModerationReportsResponseDto> listReports({
    String? status,
    int? limit,
    int? offset,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/moderation/reports',
        queryParameters: <String, dynamic>{
          if (status != null && status.isNotEmpty) 'status': status,
          'limit': _limit(limit),
          'offset': _offset(offset),
        },
      );
      return ModerationReportsResponseDto.fromJson(response.data!);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<Map<String, dynamic>> updateReport({
    required String reportId,
    required String status,
    String? resolutionNote,
  }) async {
    try {
      final response = await _dio.patch<Map<String, dynamic>>(
        '/moderation/reports/$reportId',
        data: <String, dynamic>{
          'status': status,
          if (resolutionNote != null && resolutionNote.trim().isNotEmpty)
            'resolution_note': resolutionNote.trim(),
        },
      );
      return response.data!;
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<String> banUser({
    required String userId,
    required String reasonText,
    DateTime? endsAt,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/moderation/users/$userId/ban',
        data: <String, dynamic>{
          'reason_text': reasonText,
          if (endsAt != null) 'ends_at': endsAt.toUtc().toIso8601String(),
        },
      );
      return response.data!['ban_id'] as String;
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<bool> test() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/moderation/test');
      return response.data?['ok'] == true;
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}
