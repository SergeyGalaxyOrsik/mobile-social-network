class ModerationReport {
  const ModerationReport(this.values);

  final Map<String, dynamic> values;

  String? get reportId =>
      values['reportId'] as String? ??
      values['report_id'] as String? ??
      values['id'] as String?;

  String? get status => values['status'] as String?;
}

class BanUserResult {
  const BanUserResult({required this.banId});

  final String banId;
}
