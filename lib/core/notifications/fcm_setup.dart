import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import 'package:mobile_social_network/firebase_options.dart';

/// Обработчик уведомлений в фоновом isolate. Должен быть top-level.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  if (kDebugMode) {
    debugPrint(
      'FCM background: id=${message.messageId} data=${message.data}',
    );
  }
}

/// Разрешения и отключение дублирующего системного баннера iOS в foreground
/// (in-app показ через [PushNavigation.showForegroundBanner]).
Future<void> setupFirebaseMessaging() async {
  final messaging = FirebaseMessaging.instance;

  final settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );
  if (kDebugMode) {
    debugPrint('FCM permission: ${settings.authorizationStatus}');
  }

  await messaging.setForegroundNotificationPresentationOptions(
    alert: false,
    badge: true,
    sound: true,
  );
}
