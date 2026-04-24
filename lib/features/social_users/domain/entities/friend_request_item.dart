class FriendRequestItem {
  const FriendRequestItem({
    required this.requestId,
    required this.peerUserId,
    required this.peerUsername,
    required this.createdAt,
    required this.incoming,
  });

  final String requestId;
  final String peerUserId;
  final String peerUsername;
  final String createdAt;
  /// `true` — входящая заявка (вам отправили), `false` — исходящая.
  final bool incoming;
}
