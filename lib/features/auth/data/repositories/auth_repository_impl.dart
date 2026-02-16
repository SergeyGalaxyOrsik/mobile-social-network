import 'package:shared_preferences/shared_preferences.dart';

import 'package:mobile_social_network/features/auth/domain/entities/user_entity.dart';
import 'package:mobile_social_network/features/auth/domain/repositories/auth_repository.dart';
import 'package:mobile_social_network/features/auth/domain/repositories/user_repository.dart';

const _keyCurrentUserEmail = 'current_user_email';

/// Реализация репозитория авторизации (слой data).
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required UserRepository userRepository,
    required SharedPreferences preferences,
  })  : _userRepository = userRepository,
        _preferences = preferences;

  final UserRepository _userRepository;
  final SharedPreferences _preferences;

  @override
  Future<UserEntity?> getCurrentUser() async {
    final email = _preferences.getString(_keyCurrentUserEmail);
    if (email == null || email.isEmpty) return null;
    return _userRepository.getUserByEmail(email);
  }

  @override
  Future<UserEntity?> signIn(String email, String password) async {
    final ok = await _userRepository.checkPassword(email, password);
    if (!ok) return null;
    await _preferences.setString(_keyCurrentUserEmail, email);
    return _userRepository.getUserByEmail(email);
  }

  @override
  Future<UserEntity?> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    final exists = await _userRepository.existsUserByEmail(email);
    if (exists) return null;
    final user = UserEntity(
      id: '',
      email: email.trim(),
      displayName: displayName?.trim().isNotEmpty == true ? displayName!.trim() : null,
      password: password,
    );
    await _userRepository.createUser(user);
    await _preferences.setString(_keyCurrentUserEmail, email.trim());
    return _userRepository.getUserByEmail(email.trim());
  }

  @override
  Future<void> signOut() async {
    await _preferences.remove(_keyCurrentUserEmail);
  }
}
