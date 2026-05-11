import 'package:flutter/material.dart';

class DirectChatRouteArgs {
  const DirectChatRouteArgs({required this.peerUserId, this.peerDisplayName});

  final String peerUserId;
  final String? peerDisplayName;
}

void pushConversationsPage(BuildContext context) {
  Navigator.of(context).pushNamed<void>('/conversations');
}

void pushDirectChatPage(
  BuildContext context, {
  required String peerUserId,
  String? peerDisplayName,
}) {
  Navigator.of(context).pushNamed<void>(
    '/chat',
    arguments: DirectChatRouteArgs(
      peerUserId: peerUserId,
      peerDisplayName: peerDisplayName,
    ),
  );
}

void pushChatBlocksPage(BuildContext context) {
  Navigator.of(context).pushNamed<void>('/chat/blocks');
}
