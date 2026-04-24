/// Публичные данные автора поста из API (`author` в `PostResponseDto`).
class PostAuthor {
  const PostAuthor({
    required this.username,
    this.bio,
    this.avatarUrl,
    this.avatarMediaId,
  });

  final String username;
  final String? bio;
  final String? avatarUrl;
  final String? avatarMediaId;

  Map<String, dynamic> toJson() => {
    'username': username,
    if (bio != null) 'bio': bio,
    if (avatarUrl != null) 'avatar_url': avatarUrl,
    if (avatarMediaId != null) 'avatar_media_id': avatarMediaId,
  };

  factory PostAuthor.fromJson(Map<String, dynamic> json) {
    return PostAuthor(
      username: json['username'] as String? ?? '',
      bio: json['bio'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      avatarMediaId: json['avatar_media_id'] as String?,
    );
  }
}
