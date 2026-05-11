import 'package:mobile_social_network/features/notifications/data/datasources/notifications_remote_datasource.dart';
import 'package:mobile_social_network/features/notifications/data/models/notifications_api_models.dart';
import 'package:mobile_social_network/features/notifications/domain/entities/app_notification.dart';
import 'package:mobile_social_network/features/notifications/domain/repositories/notifications_repository.dart';

class NotificationsRepositoryImpl implements NotificationsRepository {
  NotificationsRepositoryImpl(this._remote);

  final NotificationsRemoteDataSource _remote;

  @override
  Future<({List<AppNotification> items, int total})> list({
    int limit = 20,
    int offset = 0,
    bool? unreadOnly,
  }) async {
    final dto = await _remote.list(
      limit: limit,
      offset: offset,
      unreadOnly: unreadOnly,
    );
    return (items: dto.items.map(_notification).toList(), total: dto.total);
  }

  @override
  Future<void> markAllRead() => _remote.markAllRead();

  @override
  Future<void> markRead(String notificationId) =>
      _remote.markRead(notificationId);

  @override
  Future<List<NotificationPreferenceItem>> getPreferences() async {
    final dto = await _remote.getPreferences();
    return dto.items.map(_preference).toList();
  }

  @override
  Future<List<NotificationPreferenceItem>> updatePreferences(
    List<NotificationPreferenceItem> items,
  ) async {
    final dto = await _remote.updatePreferences(
      items
          .map(
            (e) => NotificationPreferenceItemDto(
              typeCode: e.typeCode,
              pushEnabled: e.pushEnabled,
              inAppEnabled: e.inAppEnabled,
            ),
          )
          .toList(),
    );
    return dto.items.map(_preference).toList();
  }

  AppNotification _notification(NotificationDto dto) => AppNotification(
    notificationId: dto.notificationId,
    typeCode: dto.typeCode,
    title: dto.title.isEmpty ? dto.typeCode : dto.title,
    body: dto.body,
    readAt: dto.readAt,
    createdAt: dto.createdAt,
  );

  NotificationPreferenceItem _preference(NotificationPreferenceItemDto dto) =>
      NotificationPreferenceItem(
        typeCode: dto.typeCode,
        pushEnabled: dto.pushEnabled,
        inAppEnabled: dto.inAppEnabled,
      );
}
