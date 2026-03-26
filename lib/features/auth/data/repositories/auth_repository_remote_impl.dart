import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:mobile_social_network/core/constants/app_constants.dart';
import 'package:mobile_social_network/core/network/api_exception.dart';
import 'package:mobile_social_network/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:mobile_social_network/features/auth/data/mappers/auth_user_dto_mapper.dart';
import 'package:mobile_social_network/features/auth/data/models/auth_tokens_response_dto.dart';
import 'package:mobile_social_network/features/auth/data/models/auth_user_view_dto.dart';
import 'package:mobile_social_network/features/auth/data/models/login_dto.dart';
import 'package:mobile_social_network/features/auth/data/models/register_dto.dart';
import 'package:mobile_social_network/features/auth/domain/entities/user_entity.dart';
import 'package:mobile_social_network/features/auth/domain/repositories/auth_repository.dart';

const _keyCurrentUserEmail = 'current_user_email';
const _keyUserJson = 'current_user_json';

class AuthRepositoryRemoteImpl implements AuthRepository {
  AuthRepositoryRemoteImpl({
    required AuthRemoteDataSource remote,
    required SharedPreferences preferences,
  }) : _remote = remote,
       _prefs = preferences;

  final AuthRemoteDataSource _remote;
  final SharedPreferences _prefs;

  Future<void> _persistSession(AuthTokensResponseDto dto) async {
    await _prefs.setString(AppConstants.accessTokenKey, dto.accessToken);
    await _prefs.setString(_keyUserJson, jsonEncode(dto.user.toJson()));
    await _prefs.setString(_keyCurrentUserEmail, dto.user.email);
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    final token = _prefs.getString(AppConstants.accessTokenKey);
    if (token == null || token.isEmpty) return null;
    try {
      final dto = await _remote.me();
      await _prefs.setString(_keyUserJson, jsonEncode(dto.toJson()));
      await _prefs.setString(_keyCurrentUserEmail, dto.email);
      return dto.toEntity();
    } on ApiException catch (e) {
      if (e.statusCode == 401) {
        await signOut();
        return null;
      }
      final cached = _prefs.getString(_keyUserJson);
      if (cached != null) {
        try {
          return AuthUserViewDto.fromJson(
            jsonDecode(cached) as Map<String, dynamic>,
          ).toEntity();
        } catch (_) {}
      }
      return null;
    }
  }

  @override
  Future<UserEntity?> signIn(String email, String password) async {
    try {
      final dto = await _remote.login(
        LoginDto(email: email.trim(), password: password),
      );
      await _persistSession(dto);
      return dto.user.toEntity();
    } on ApiException {
      return null;
    }
  }

  @override
  Future<UserEntity?> signUp({
    required String email,
    required String password,
    String? username,
  }) async {
    final un = username?.trim();
    if (un == null || un.isEmpty) return null;
    try {
      final dto = await _remote.register(
        RegisterDto(email: email.trim(), password: password, username: un),
      );
      await _persistSession(dto);
      return dto.user.toEntity();
    } on ApiException {
      return null;
    }
  }

  @override
  Future<void> signOut() async {
    await _prefs.remove(AppConstants.accessTokenKey);
    await _prefs.remove(_keyUserJson);
    await _prefs.remove(_keyCurrentUserEmail);
  }
}
