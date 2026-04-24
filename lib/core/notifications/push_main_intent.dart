import 'package:flutter/foundation.dart';

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
  final int? friendsTabIndex;
  final String? highlightIncomingRequestId;
  final bool resetFriendRequestHighlight;
  final bool refreshFeed;
  final bool reloadFriendRequests;
}

class PushMainIntentBus {
  PushMainIntentBus._();

  static final ValueNotifier<PushMainIntent?> pending =
      ValueNotifier<PushMainIntent?>(null);

  static void publish(PushMainIntent intent) {
    pending.value = intent;
  }
}
