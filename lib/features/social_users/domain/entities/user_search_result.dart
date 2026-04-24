class UserSearchResult {
  const UserSearchResult({
    required this.userId,
    required this.username,
    this.bio,
  });

  final String userId;
  final String username;
  final String? bio;
}
