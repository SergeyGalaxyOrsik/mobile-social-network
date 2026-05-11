class NotificationDto {
  const NotificationDto({
    required this.notificationId,
    required this.typeCode,
    required this.title,
    this.body,
    this.readAt,
    this.createdAt,
    this.data = const {},
  });

  final String notificationId;
  final String typeCode;
  final String title;
  final String? body;
  final String? readAt;
  final String? createdAt;
  final Map<String, dynamic> data;

  factory NotificationDto.fromJson(Map<String, dynamic> json) {
    return NotificationDto(
      notificationId:
          json['notificationId'] as String? ??
          json['notification_id'] as String? ??
          json['id'] as String? ??
          '',
      typeCode:
          json['typeCode'] as String? ?? json['type_code'] as String? ?? '',
      title: json['title'] as String? ?? json['type_code'] as String? ?? '',
      body: json['body'] as String? ?? json['message'] as String?,
      readAt: json['readAt'] as String? ?? json['read_at'] as String?,
      createdAt: json['createdAt'] as String? ?? json['created_at'] as String?,
      data: (json['data'] as Map<String, dynamic>?) ?? const {},
    );
  }
}

class NotificationsListResponseDto {
  const NotificationsListResponseDto({
    required this.items,
    required this.total,
  });

  final List<NotificationDto> items;
  final int total;

  factory NotificationsListResponseDto.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List<dynamic>? ?? const [];
    final rawTotal = json['total'];
    return NotificationsListResponseDto(
      items: rawItems
          .map((e) => NotificationDto.fromJson(e as Map<String, dynamic>))
          .where((e) => e.notificationId.isNotEmpty)
          .toList(),
      total: rawTotal is num ? rawTotal.toInt() : rawItems.length,
    );
  }
}

class NotificationPreferenceItemDto {
  const NotificationPreferenceItemDto({
    required this.typeCode,
    required this.pushEnabled,
    required this.inAppEnabled,
  });

  final String typeCode;
  final bool pushEnabled;
  final bool inAppEnabled;

  factory NotificationPreferenceItemDto.fromJson(Map<String, dynamic> json) {
    return NotificationPreferenceItemDto(
      typeCode:
          json['typeCode'] as String? ?? json['type_code'] as String? ?? '',
      pushEnabled:
          json['pushEnabled'] as bool? ?? json['push_enabled'] as bool? ?? true,
      inAppEnabled:
          json['inAppEnabled'] as bool? ??
          json['in_app_enabled'] as bool? ??
          true,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'type_code': typeCode,
    'push_enabled': pushEnabled,
    'in_app_enabled': inAppEnabled,
  };
}

class NotificationPreferencesResponseDto {
  const NotificationPreferencesResponseDto({required this.items});

  final List<NotificationPreferenceItemDto> items;

  factory NotificationPreferencesResponseDto.fromJson(
    Map<String, dynamic> json,
  ) {
    final rawItems = json['items'] as List<dynamic>? ?? const [];
    return NotificationPreferencesResponseDto(
      items: rawItems
          .map(
            (e) => NotificationPreferenceItemDto.fromJson(
              e as Map<String, dynamic>,
            ),
          )
          .where((e) => e.typeCode.isNotEmpty)
          .toList(),
    );
  }
}
