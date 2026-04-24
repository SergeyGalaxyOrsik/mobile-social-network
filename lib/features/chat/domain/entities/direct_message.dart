import 'package:equatable/equatable.dart';

import 'package:mobile_social_network/features/chat/domain/entities/chat_media_attachment.dart';

class DirectMessage extends Equatable {
  const DirectMessage({
    required this.messageId,
    required this.conversationId,
    required this.senderId,
    this.body,
    required this.createdAt,
    this.media = const [],
  });

  final String messageId;
  final String conversationId;
  final String senderId;
  final String? body;
  final String createdAt;
  final List<ChatMediaAttachment> media;

  @override
  List<Object?> get props => [
    messageId,
    conversationId,
    senderId,
    body,
    createdAt,
    media,
  ];
}
