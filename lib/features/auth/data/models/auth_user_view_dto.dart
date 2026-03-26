class AuthUserViewDto {
  const AuthUserViewDto({
    required this.userId,
    required this.email,
    required this.username,
    this.avatarUrl,
  });

  final String userId;
  final String email;
  final String username;
  final String? avatarUrl;

  factory AuthUserViewDto.fromJson(Map<String, dynamic> json) {
    return AuthUserViewDto(
      userId: json['userId'] as String,
      email: json['email'] as String,
      username: json['username'] as String,
      avatarUrl: _parseAvatarUrl(json['avatarUrl']),
    );
  }

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'email': email,
    'username': username,
    'avatarUrl': avatarUrl,
  };

  static String? _parseAvatarUrl(dynamic value) {
    if (value == null) return null;
    if (value is String) return value;
    return null;
  }
}
