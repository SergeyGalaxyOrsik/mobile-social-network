import 'package:mobile_social_network/features/auth/domain/entities/user_entity.dart';

/// Контракт репозитория авторизации (доменный слой).
abstract class AuthRepository {
  Future<UserEntity?> getCurrentUser();
  Future<UserEntity?> signIn(String email, String password);
  /// Регистрация: создаёт пользователя и выполняет вход. null при ошибке (например email занят).
  Future<UserEntity?> signUp({
    required String email,
    required String password,
    String? displayName,
  });
  Future<void> signOut();
}
