import 'package:mobile_social_network/features/reports/data/datasources/reports_remote_datasource.dart';
import 'package:mobile_social_network/features/reports/domain/entities/report_target_type.dart';
import 'package:mobile_social_network/features/reports/domain/repositories/reports_repository.dart';
import 'package:mobile_social_network/features/social_users/domain/entities/report_reason_code.dart';

class ReportsRepositoryImpl implements ReportsRepository {
  ReportsRepositoryImpl(this._remote);

  final ReportsRemoteDataSource _remote;

  @override
  Future<String> createReport({
    required ReportTargetType targetType,
    required String targetId,
    required ReportReasonCode reason,
    String? details,
  }) {
    return _remote.createReport(
      targetType: targetType,
      targetId: targetId,
      reason: reason,
      details: details,
    );
  }
}
