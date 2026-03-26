/// Сущность пользователя (доменный слой).
class UserEntity {
  final String id;
  final String email;
  /// Публичное имя (OpenAPI: username). В БД колонка по-прежнему `displayName`.
  final String? username;
  final String? password;
  final String? avatarUrl;

  const UserEntity({
    required this.id,
    required this.email,
    this.username,
    this.password,
    this.avatarUrl,
  });

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'email': email,
      'displayName': username,
      'avatarUrl': avatarUrl,
    };
    if (password != null) {
      map['password'] = password;
    }
    map['id'] = id;
    return map;
  }

  factory UserEntity.fromMap(Map<String, dynamic> map) {
    return UserEntity(
      id: map['id']?.toString() ?? '',
      email: map['email'],
      username: map['username'] ?? map['displayName'],
      avatarUrl: map['avatarUrl'],
    );
  }
}
