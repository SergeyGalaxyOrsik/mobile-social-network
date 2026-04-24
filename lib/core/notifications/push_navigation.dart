import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'package:mobile_social_network/core/navigation/app_navigator_keys.dart';
import 'package:mobile_social_network/core/notifications/push_event_parser.dart';
import 'package:mobile_social_network/core/notifications/push_main_intent.dart';
import 'package:mobile_social_network/l10n/app_localizations.dart';
import 'package:mobile_social_network/features/social_users/presentation/pages/user_profile_page.dart';

/// Сообщение из уведомления до завершения входа (cold start по тапу).
class PendingPushOpenMessage {
  PendingPushOpenMessage._();

  static RemoteMessage? _queued;

  static void assign(RemoteMessage message) {
    _queued = message;
  }

  static RemoteMessage? take() {
    final m = _queued;
    _queued = null;
    return m;
  }
}

/// Навигация и in-app UI по контракту FCM `data`.
abstract final class PushNavigation {
  /// Пользователь открыл приложение из системного уведомления.
  static void handleNotificationOpened(RemoteMessage message) {
    final parsed = ParsedPushMessage.tryParse(message.data);
    if (parsed == null) {
      return;
    }
    _route(parsed);
  }

  /// Сообщение на переднем плане: баннер по `data`, действие «Открыть» ведёт на экран.
  static void showForegroundBanner(RemoteMessage message) {
    final parsed = ParsedPushMessage.tryParse(message.data);
    if (parsed == null) {
      return;
    }
    final messenger = appRootMessengerKey.currentState;
    if (messenger == null) {
      return;
    }
    final navCtx = appRootNavigatorKey.currentContext;
    final l10n = navCtx != null ? AppLocalizations.of(navCtx) : null;

    final title = message.notification?.title ?? _fallbackTitle(parsed, l10n);
    final body = message.notification?.body ?? _fallbackBody(parsed, l10n);

    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          body.isNotEmpty ? '$title\n$body' : title,
          maxLines: 4,
          overflow: TextOverflow.ellipsis,
        ),
        action: SnackBarAction(
          label: l10n?.pushNotificationOpenAction ?? 'Open',
          onPressed: () => _route(parsed),
        ),
      ),
    );
  }

  static void _route(ParsedPushMessage p) {
    switch (p.event) {
      case PushServerEvent.friendRequest:
        final rid = p.requestId;
        PushMainIntentBus.publish(
          PushMainIntent(
            selectedTabIndex: 1,
            friendsTabIndex: 2,
            highlightIncomingRequestId: rid,
            reloadFriendRequests: true,
          ),
        );
        break;
      case PushServerEvent.friendAdded:
        final id = p.peerUserId;
        if (id == null) {
          return;
        }
        SchedulerBinding.instance.addPostFrameCallback((_) {
          final ctx = appShellNavigatorKey.currentContext;
          if (ctx != null && ctx.mounted) {
            pushUserProfilePage(ctx, id);
          }
        });
        break;
      case PushServerEvent.friendPost:
        PushMainIntentBus.publish(
          const PushMainIntent(
            selectedTabIndex: 0,
            refreshFeed: true,
            resetFriendRequestHighlight: true,
          ),
        );
        break;
      case PushServerEvent.unknown:
        break;
    }
  }

  static String _fallbackTitle(ParsedPushMessage p, AppLocalizations? l10n) {
    switch (p.event) {
      case PushServerEvent.friendRequest:
        return l10n?.pushNotificationFriendRequestTitle ?? 'Friend request';
      case PushServerEvent.friendAdded:
        return l10n?.pushNotificationFriendAddedTitle ?? 'New friend';
      case PushServerEvent.friendPost:
        return l10n?.pushNotificationFriendPostTitle ?? 'New post';
      case PushServerEvent.unknown:
        return '';
    }
  }

  static String _fallbackBody(ParsedPushMessage p, AppLocalizations? l10n) {
    switch (p.event) {
      case PushServerEvent.friendRequest:
        final name = p.fromUsername ?? '';
        if (l10n != null && name.isNotEmpty) {
          return l10n.pushNotificationFriendRequestBody(name);
        }
        return name;
      case PushServerEvent.friendAdded:
        final name = p.peerUsername ?? '';
        if (l10n != null && name.isNotEmpty) {
          return l10n.pushNotificationFriendAddedBody(name);
        }
        return name;
      case PushServerEvent.friendPost:
        final name = p.authorUsername ?? '';
        if (l10n != null && name.isNotEmpty) {
          return l10n.pushNotificationFriendPostBody(name);
        }
        return name;
      case PushServerEvent.unknown:
        return '';
    }
  }
}
