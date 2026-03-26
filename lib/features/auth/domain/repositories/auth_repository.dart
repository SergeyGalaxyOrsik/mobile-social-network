import 'package:mobile_social_network/features/auth/domain/entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity?> getCurrentUser();
  Future<UserEntity?> signIn(String email, String password);
  Future<UserEntity?> signUp({
    required String email,
    required String password,
    String? username,
  });
  Future<void> signOut();
}
