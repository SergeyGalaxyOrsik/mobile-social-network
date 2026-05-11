import 'package:mobile_social_network/features/reports/domain/entities/report_target_type.dart';
import 'package:mobile_social_network/features/social_users/domain/entities/report_reason_code.dart';

abstract class ReportsRepository {
  Future<String> createReport({
    required ReportTargetType targetType,
    required String targetId,
    required ReportReasonCode reason,
    String? details,
  });
}
