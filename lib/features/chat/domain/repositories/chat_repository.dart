import 'package:mobile_social_network/features/chat/domain/entities/direct_block.dart';
import 'package:mobile_social_network/features/chat/domain/entities/direct_conversation.dart';
import 'package:mobile_social_network/features/chat/domain/entities/direct_message.dart';
import 'package:mobile_social_network/features/chat/domain/entities/direct_message_deleted.dart';

abstract class ChatRepository {
  Future<List<DirectConversation>> fetchConversations({
    int limit = 20,
    int offset = 0,
  });

  Future<List<DirectMessage>> fetchMessages(
    String peerUserId, {
    int limit = 30,
    int offset = 0,
  });

  /// Sends via WebSocket when connected; otherwise POST.
  Future<DirectMessage> sendDirectMessage({
    required String peerUserId,
    String? body,
    List<String> mediaIds = const [],
  });

  Future<void> deleteMessage(String messageId);

  Future<void> markMessageRead({
    required String messageId,
    required String peerUserId,
  });

  Future<List<DirectBlock>> fetchBlocks();

  Future<void> blockUser(String blockedUserId);

  Future<void> unblockUser(String blockedUserId);

  Stream<DirectMessage> get incomingDirectMessages;

  /// Сокет `direct:message_deleted` после `DELETE` сообщения.
  Stream<DirectMessageDeleted> get incomingDirectMessageDeletions;

  /// Connects Socket.IO when user is authenticated.
  Future<void> activateRealtime();

  void deactivateRealtime();

  /// Subscribe to server room for [peerUserId]; returns [conversationId] from ack.
  Future<String?> subscribePeer(String peerUserId);
}
