/// Событие сокета `direct:message_deleted` ([docs/API_CHAT.md](docs/API_CHAT.md)).
class DirectMessageDeleted {
  const DirectMessageDeleted({
    required this.conversationId,
    required this.messageId,
  });

  final String conversationId;
  final String messageId;
}
