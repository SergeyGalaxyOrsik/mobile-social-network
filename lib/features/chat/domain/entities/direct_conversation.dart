import 'package:equatable/equatable.dart';

import 'package:mobile_social_network/features/chat/domain/entities/direct_message.dart';

class DirectConversation extends Equatable {
  const DirectConversation({
    required this.conversationId,
    required this.peerUserId,
    required this.lastActivityAt,
    this.lastMessage,
  });

  final String conversationId;
  final String peerUserId;
  final String lastActivityAt;
  final DirectMessage? lastMessage;

  @override
  List<Object?> get props => [
    conversationId,
    peerUserId,
    lastActivityAt,
    lastMessage,
  ];
}
