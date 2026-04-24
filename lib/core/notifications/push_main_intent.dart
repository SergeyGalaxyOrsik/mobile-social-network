import 'package:flutter/foundation.dart';

/// Команда главному экрану после разбора push (вкладки, подсветка, обновление ленты).
class PushMainIntent {
  const PushMainIntent({
    this.selectedTabIndex,
    this.friendsTabIndex,
    this.highlightIncomingRequestId,
    this.resetFriendRequestHighlight = false,
    this.refreshFeed = false,
    this.reloadFriendRequests = false,
  });

  final int? selectedTabIndex;
  /// Индекс вкладки внутри экрана «Друзья»: 0 поиск людей, 1 мои друзья, 2 входящие, 3 исходящие.
  final int? friendsTabIndex;
  final String? highlightIncomingRequestId;
  /// Сброс подсветки заявки (например при переходе к ленте по `friend_post`).
  final bool resetFriendRequestHighlight;
  final bool refreshFeed;
  final bool reloadFriendRequests;
}

/// Очередь навигации для [MainPage] (контекст кубитов есть только под главным виджетом).
class PushMainIntentBus {
  PushMainIntentBus._();

  static final ValueNotifier<PushMainIntent?> pending =
      ValueNotifier<PushMainIntent?>(null);

  static void publish(PushMainIntent intent) {
    pending.value = intent;
  }
}
