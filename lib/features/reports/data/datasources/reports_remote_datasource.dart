import 'package:dio/dio.dart';

import 'package:mobile_social_network/core/network/api_exception.dart';
import 'package:mobile_social_network/features/reports/domain/entities/report_target_type.dart';
import 'package:mobile_social_network/features/social_users/domain/entities/report_reason_code.dart';

class ReportsRemoteDataSource {
  ReportsRemoteDataSource(this._dio);

  final Dio _dio;

  Future<String> createReport({
    required ReportTargetType targetType,
    required String targetId,
    required ReportReasonCode reason,
    String? details,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/reports',
        data: <String, dynamic>{
          'target_type': targetType.apiValue,
          'target_id': targetId,
          'reason_code': reason.apiValue,
          if (details != null && details.trim().isNotEmpty)
            'details': details.trim(),
        },
      );
      return response.data!['report_id'] as String;
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}
