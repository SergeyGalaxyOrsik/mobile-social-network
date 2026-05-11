import 'package:mobile_social_network/features/moderation/data/datasources/moderation_remote_datasource.dart';
import 'package:mobile_social_network/features/moderation/domain/entities/moderation_report.dart';
import 'package:mobile_social_network/features/moderation/domain/repositories/moderation_repository.dart';

class ModerationRepositoryImpl implements ModerationRepository {
  ModerationRepositoryImpl(this._remote);

  final ModerationRemoteDataSource _remote;

  @override
  Future<({List<ModerationReport> items, int total})> listReports({
    String? status,
    int limit = 20,
    int offset = 0,
  }) async {
    final dto = await _remote.listReports(
      status: status,
      limit: limit,
      offset: offset,
    );
    return (
      items: dto.items.map(ModerationReport.new).toList(),
      total: dto.total,
    );
  }

  @override
  Future<ModerationReport> updateReport({
    required String reportId,
    required String status,
    String? resolutionNote,
  }) async {
    return ModerationReport(
      await _remote.updateReport(
        reportId: reportId,
        status: status,
        resolutionNote: resolutionNote,
      ),
    );
  }

  @override
  Future<BanUserResult> banUser({
    required String userId,
    required String reasonText,
    DateTime? endsAt,
  }) async {
    return BanUserResult(
      banId: await _remote.banUser(
        userId: userId,
        reasonText: reasonText,
        endsAt: endsAt,
      ),
    );
  }

  @override
  Future<bool> test() => _remote.test();
}
