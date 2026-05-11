import 'package:mobile_social_network/features/chat/data/datasources/chat_remote_datasource.dart';
import 'package:mobile_social_network/features/chat/data/datasources/chat_socket_client.dart';
import 'package:mobile_social_network/features/chat/data/mappers/chat_dto_mapper.dart';
import 'package:mobile_social_network/features/chat/domain/entities/direct_block.dart';
import 'package:mobile_social_network/features/chat/domain/entities/direct_conversation.dart';
import 'package:mobile_social_network/features/chat/domain/entities/direct_message.dart';
import 'package:mobile_social_network/features/chat/domain/entities/direct_message_deleted.dart';
import 'package:mobile_social_network/features/chat/domain/repositories/chat_repository.dart';

class ChatRepositoryImpl implements ChatRepository {
  ChatRepositoryImpl({
    required ChatRemoteDataSource remote,
    required ChatSocketClient socket,
  }) : _remote = remote,
       _socket = socket;

  final ChatRemoteDataSource _remote;
  final ChatSocketClient _socket;

  @override
  Stream<DirectMessage> get incomingDirectMessages => _socket.incomingMessages;

  @override
  Stream<DirectMessageDeleted> get incomingDirectMessageDeletions =>
      _socket.incomingMessageDeletions;

  @override
  Future<void> activateRealtime() async {
    try {
      await _socket.connect();
    } catch (_) {
      // Offline / bad token — REST still works.
    }
  }

  @override
  void deactivateRealtime() {
    _socket.disconnect();
  }

  @override
  Future<String?> subscribePeer(String peerUserId) async {
    try {
      return await _socket.subscribePeer(peerUserId);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<DirectConversation>> fetchConversations({
    int limit = 20,
    int offset = 0,
  }) async {
    final dto = await _remote.listConversations(limit: limit, offset: offset);
    return dto.items.map((e) => e.toEntity()).toList();
  }

  @override
  Future<List<DirectMessage>> fetchMessages(
    String peerUserId, {
    int limit = 30,
    int offset = 0,
  }) async {
    final dto = await _remote.listMessages(
      peerUserId: peerUserId,
      limit: limit,
      offset: offset,
    );
    return dto.items.map((e) => e.toEntity()).toList();
  }

  @override
  Future<DirectMessage> sendDirectMessage({
    required String peerUserId,
    String? body,
    List<String> mediaIds = const [],
  }) async {
    try {
      final via = await _socket.trySend(
        peerUserId: peerUserId,
        body: body,
        mediaIds: mediaIds,
      );
      if (via != null && via.messageId.isNotEmpty) {
        return via;
      }
    } catch (_) {}
    final dto = await _remote.sendMessage(
      peerUserId: peerUserId,
      body: body,
      mediaIds: mediaIds,
    );
    return dto.toEntity();
  }

  @override
  Future<void> deleteMessage(String messageId) =>
      _remote.deleteMessage(messageId);

  @override
  Future<void> markMessageRead({
    required String messageId,
    required String peerUserId,
  }) => _remote.markMessageRead(messageId: messageId, peerUserId: peerUserId);

  @override
  Future<List<DirectBlock>> fetchBlocks() async {
    final dto = await _remote.listBlocks();
    return dto.items.map((e) => e.toEntity()).toList();
  }

  @override
  Future<void> blockUser(String blockedUserId) =>
      _remote.blockUser(blockedUserId);

  @override
  Future<void> unblockUser(String blockedUserId) =>
      _remote.unblockUser(blockedUserId);
}
