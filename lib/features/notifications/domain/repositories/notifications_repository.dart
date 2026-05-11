import 'package:mobile_social_network/features/notifications/domain/entities/app_notification.dart';

abstract class NotificationsRepository {
  Future<({List<AppNotification> items, int total})> list({
    int limit = 20,
    int offset = 0,
    bool? unreadOnly,
  });

  Future<void> markAllRead();

  Future<void> markRead(String notificationId);

  Future<List<NotificationPreferenceItem>> getPreferences();

  Future<List<NotificationPreferenceItem>> updatePreferences(
    List<NotificationPreferenceItem> items,
  );
}
