enum ReportTargetType { user, post, comment }

extension ReportTargetTypeApi on ReportTargetType {
  String get apiValue => switch (this) {
    ReportTargetType.user => 'user',
    ReportTargetType.post => 'post',
    ReportTargetType.comment => 'comment',
  };
}
