/// Сущность пользователя (доменный слой).
class UserEntity {
  final String id;
  final String email;
  final String? displayName;
  final String? password;

  const UserEntity({
    required this.id,
    required this.email,
    this.displayName,
    this.password,
  });

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'email': email,
      'displayName': displayName,
      'password': password,
    };
    map['id'] = id;
    return map;
  }

  /// Преобразование Map в UserEntity (пароль не возвращаем из БД).
  factory UserEntity.fromMap(Map<String, dynamic> map) {
    return UserEntity(
      id: map['id']?.toString() ?? '',
      email: map['email'],
      displayName: map['displayName'],
    );
  }
}
