import 'package:mobile_social_network/features/auth/domain/entities/user_entity.dart';

/// Контракт репозитория пользователей (доменный слой).
abstract class UserRepository {
  Future<List<UserEntity>> getUsers();
  Future<UserEntity?> getUserByEmail(String email);
  Future<bool> existsUserByEmail(String email);
  Future<void> createUser(UserEntity user);
  Future<void> updateUser(UserEntity user);
  Future<void> deleteUser(int id);
  Future<bool> checkPassword(String email, String inputPassword);
}
