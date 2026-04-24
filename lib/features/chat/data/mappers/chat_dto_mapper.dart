import 'package:mobile_social_network/features/chat/data/models/chat_api_models.dart';
import 'package:mobile_social_network/features/chat/domain/entities/chat_media_attachment.dart';
import 'package:mobile_social_network/features/chat/domain/entities/direct_block.dart';
import 'package:mobile_social_network/features/chat/domain/entities/direct_conversation.dart';
import 'package:mobile_social_network/features/chat/domain/entities/direct_message.dart';

extension ChatMediaItemDtoX on ChatMediaItemDto {
  ChatMediaAttachment toEntity() {
    return ChatMediaAttachment(
      mediaId: mediaId,
      url: url,
      contentType: contentType,
    );
  }
}

extension DirectMessageDtoX on DirectMessageDto {
  DirectMessage toEntity() {
    return DirectMessage(
      messageId: messageId,
      conversationId: conversationId,
      senderId: senderId,
      body: body,
      createdAt: createdAt,
      media: media.map((m) => m.toEntity()).toList(),
    );
  }
}

extension DirectConversationDtoX on DirectConversationDto {
  DirectConversation toEntity() {
    return DirectConversation(
      conversationId: conversationId,
      peerUserId: peerUserId,
      lastActivityAt: lastActivityAt,
      lastMessage: lastMessage?.toEntity(),
    );
  }
}

extension DirectBlockDtoX on DirectBlockDto {
  DirectBlock toEntity() {
    return DirectBlock(userId: userId, blockedAt: blockedAt);
  }
}
