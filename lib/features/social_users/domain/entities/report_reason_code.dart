/// Допустимые значения `reason_code` для POST `/users/:id/reports`.
enum ReportReasonCode {
  spam,
  harassment,
  hate,
  impersonation,
  nudity,
  scam,
  other,
}

extension ReportReasonCodeApi on ReportReasonCode {
  String get apiValue => switch (this) {
    ReportReasonCode.spam => 'spam',
    ReportReasonCode.harassment => 'harassment',
    ReportReasonCode.hate => 'hate',
    ReportReasonCode.impersonation => 'impersonation',
    ReportReasonCode.nudity => 'nudity',
    ReportReasonCode.scam => 'scam',
    ReportReasonCode.other => 'other',
  };

  static ReportReasonCode? tryParse(String raw) {
    return switch (raw) {
      'spam' => ReportReasonCode.spam,
      'harassment' => ReportReasonCode.harassment,
      'hate' => ReportReasonCode.hate,
      'impersonation' => ReportReasonCode.impersonation,
      'nudity' => ReportReasonCode.nudity,
      'scam' => ReportReasonCode.scam,
      'other' => ReportReasonCode.other,
      _ => null,
    };
  }
}
