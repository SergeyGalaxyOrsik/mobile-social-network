class AppNotification {
  const AppNotification({
    required this.notificationId,
    required this.typeCode,
    required this.title,
    this.body,
    this.readAt,
    this.createdAt,
  });

  final String notificationId;
  final String typeCode;
  final String title;
  final String? body;
  final String? readAt;
  final String? createdAt;

  bool get isUnread => readAt == null || readAt!.isEmpty;
}

class NotificationPreferenceItem {
  const NotificationPreferenceItem({
    required this.typeCode,
    required this.pushEnabled,
    required this.inAppEnabled,
  });

  final String typeCode;
  final bool pushEnabled;
  final bool inAppEnabled;

  NotificationPreferenceItem copyWith({bool? pushEnabled, bool? inAppEnabled}) {
    return NotificationPreferenceItem(
      typeCode: typeCode,
      pushEnabled: pushEnabled ?? this.pushEnabled,
      inAppEnabled: inAppEnabled ?? this.inAppEnabled,
    );
  }
}
