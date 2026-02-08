import 'package:mobile_social_network/features/auth/domain/entities/user_entity.dart';

/// Контракт репозитория авторизации (доменный слой).
abstract class AuthRepository {
  Future<UserEntity?> getCurrentUser();
  Future<void> signOut();
}
