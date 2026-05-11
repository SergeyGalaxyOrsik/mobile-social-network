import 'package:mobile_social_network/features/moderation/domain/entities/moderation_report.dart';

abstract class ModerationRepository {
  Future<({List<ModerationReport> items, int total})> listReports({
    String? status,
    int limit = 20,
    int offset = 0,
  });

  Future<ModerationReport> updateReport({
    required String reportId,
    required String status,
    String? resolutionNote,
  });

  Future<BanUserResult> banUser({
    required String userId,
    required String reasonText,
    DateTime? endsAt,
  });

  Future<bool> test();
}
