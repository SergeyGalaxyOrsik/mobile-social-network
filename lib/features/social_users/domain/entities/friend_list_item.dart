class FriendListItem {
  const FriendListItem({
    required this.userId,
    required this.username,
    this.bio,
    this.avatarMediaId,
    this.avatarUrl,
    required this.friendshipCreatedAt,
  });

  final String userId;
  final String username;
  final String? bio;
  final String? avatarMediaId;
  final String? avatarUrl;
  final String friendshipCreatedAt;
}
