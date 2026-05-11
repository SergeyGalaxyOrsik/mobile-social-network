class ChatMediaItemDto {
  const ChatMediaItemDto({
    required this.mediaId,
    required this.url,
    this.contentType,
  });

  final String mediaId;
  final String url;
  final String? contentType;

  factory ChatMediaItemDto.fromJson(Map<String, dynamic> json) {
    return ChatMediaItemDto(
      mediaId: json['media_id'] as String? ?? '',
      url: json['url'] as String? ?? '',
      contentType: json['content_type'] as String? ?? json['type'] as String?,
    );
  }
}

class DirectMessageDto {
  const DirectMessageDto({
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
  final List<ChatMediaItemDto> media;

  factory DirectMessageDto.fromJson(Map<String, dynamic> json) {
    final rawMedia = json['media'] as List<dynamic>?;
    return DirectMessageDto(
      messageId: json['message_id'] as String? ?? '',
      conversationId: json['conversation_id'] as String? ?? '',
      senderId: json['sender_id'] as String? ?? '',
      body: json['body'] as String?,
      createdAt: json['created_at'] as String? ?? '',
      media: rawMedia == null
          ? const []
          : rawMedia
                .map(
                  (e) => ChatMediaItemDto.fromJson(e as Map<String, dynamic>),
                )
                .where((m) => m.mediaId.isNotEmpty)
                .toList(),
    );
  }
}

class DirectConversationDto {
  const DirectConversationDto({
    required this.conversationId,
    required this.peerUserId,
    required this.lastActivityAt,
    this.lastMessage,
  });

  final String conversationId;
  final String peerUserId;
  final String lastActivityAt;
  final DirectMessageDto? lastMessage;

  factory DirectConversationDto.fromJson(Map<String, dynamic> json) {
    final rawLast = json['last_message'];
    return DirectConversationDto(
      conversationId: json['conversation_id'] as String? ?? '',
      peerUserId: json['peer_user_id'] as String? ?? '',
      lastActivityAt: json['last_activity_at'] as String? ?? '',
      lastMessage: rawLast is Map<String, dynamic>
          ? DirectMessageDto.fromJson(rawLast)
          : null,
    );
  }
}

class DirectBlockDto {
  const DirectBlockDto({required this.userId, required this.blockedAt});

  final String userId;
  final String blockedAt;

  factory DirectBlockDto.fromJson(Map<String, dynamic> json) {
    return DirectBlockDto(
      userId: json['user_id'] as String? ?? '',
      blockedAt: json['blocked_at'] as String? ?? '',
    );
  }
}

List<Map<String, dynamic>> _itemsList(Map<String, dynamic> root) {
  final items = root['items'];
  if (items is List<dynamic>) {
    return items.map((e) => e as Map<String, dynamic>).toList();
  }
  final messages = root['messages'];
  if (messages is List<dynamic>) {
    return messages.map((e) => e as Map<String, dynamic>).toList();
  }
  return const [];
}

class DirectConversationsResponseDto {
  const DirectConversationsResponseDto({required this.items});

  final List<DirectConversationDto> items;

  factory DirectConversationsResponseDto.fromJson(Map<String, dynamic> json) {
    final rows = _itemsList(json);
    return DirectConversationsResponseDto(
      items: rows
          .map(DirectConversationDto.fromJson)
          .where((e) => e.conversationId.isNotEmpty && e.peerUserId.isNotEmpty)
          .toList(),
    );
  }
}

class DirectMessagesResponseDto {
  const DirectMessagesResponseDto({required this.items});

  final List<DirectMessageDto> items;

  factory DirectMessagesResponseDto.fromJson(Map<String, dynamic> json) {
    final rows = _itemsList(json);
    return DirectMessagesResponseDto(
      items: rows
          .map(DirectMessageDto.fromJson)
          .where((e) => e.messageId.isNotEmpty)
          .toList(),
    );
  }
}

class DirectBlocksResponseDto {
  const DirectBlocksResponseDto({required this.items});

  final List<DirectBlockDto> items;

  factory DirectBlocksResponseDto.fromJson(Map<String, dynamic> json) {
    final rows = _itemsList(json);
    return DirectBlocksResponseDto(
      items: rows
          .map(DirectBlockDto.fromJson)
          .where((e) => e.userId.isNotEmpty)
          .toList(),
    );
  }
}
