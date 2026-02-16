import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mobile_social_network/core/utils/avatar_generator.dart';
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

  /// Преобразует avatarUrl в абсолютный путь (текущий Documents).
  /// В БД храним относительный путь (avatars/id.png), чтобы после переустановки
  /// приложения путь оставался валидным. Старые записи с абсолютным путём
  /// пересобираем в текущий контейнер по шаблону avatars/{id}.png.
  Future<UserEntity> _resolveAvatarPath(UserEntity user) async {
    if (user.avatarUrl == null) return user;
    final dir = await getApplicationDocumentsDirectory();
    final String fullPath;
    if (path.isAbsolute(user.avatarUrl!)) {
      fullPath = path.join(dir.path, 'avatars', '${user.id}.png');
    } else {
      fullPath = path.join(dir.path, user.avatarUrl!);
    }
    return UserEntity(
      id: user.id,
      email: user.email,
      displayName: user.displayName,
      password: user.password,
      avatarUrl: fullPath,
    );
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    final email = _preferences.getString(_keyCurrentUserEmail);
    if (email == null || email.isEmpty) return null;
    final user = await _userRepository.getUserByEmail(email);
    return user != null ? _resolveAvatarPath(user) : null;
  }

  @override
  Future<UserEntity?> signIn(String email, String password) async {
    final ok = await _userRepository.checkPassword(email, password);
    if (!ok) return null;
    await _preferences.setString(_keyCurrentUserEmail, email);
    final user = await _userRepository.getUserByEmail(email);
    return user != null ? _resolveAvatarPath(user) : null;
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
    final created = await _userRepository.getUserByEmail(email.trim());
    if (created == null) return null;

    final nickname = displayName?.trim().isNotEmpty == true
        ? displayName!.trim()
        : email.trim();
    try {
      final dir = await getApplicationDocumentsDirectory();
      final avatarsDir = path.join(dir.path, 'avatars');
      final avatarPath = path.join(avatarsDir, '${created.id}.png');
      final avatarRelativePath = path.join('avatars', '${created.id}.png');
      debugPrint(
        '[AuthRepository] Creating avatar: userId=${created.id}, nickname=$nickname, path=$avatarPath',
      );
      await generateAndSaveAvatar(nickname, avatarPath);
      await _userRepository.updateUser(
        UserEntity(
          id: created.id,
          email: created.email,
          displayName: created.displayName,
          password: null,
          avatarUrl: avatarRelativePath,
        ),
      );
      debugPrint('[AuthRepository] Avatar created and saved to DB: $avatarRelativePath');
    } catch (e, st) {
      debugPrint('[AuthRepository] Avatar creation failed: $e\n$st');
      // Leave avatarUrl null on failure
    }

    await _preferences.setString(_keyCurrentUserEmail, email.trim());
    final loaded = await _userRepository.getUserByEmail(email.trim());
    return loaded != null ? _resolveAvatarPath(loaded) : null;
  }

  @override
  Future<void> signOut() async {
    await _preferences.remove(_keyCurrentUserEmail);
  }
}
