import 'package:mobile_social_network/features/user_settings/data/datasources/user_settings_remote_datasource.dart';
import 'package:mobile_social_network/features/user_settings/data/models/user_preferences_dto.dart';
import 'package:mobile_social_network/features/user_settings/domain/entities/user_preferences.dart';
import 'package:mobile_social_network/features/user_settings/domain/repositories/user_settings_repository.dart';

class UserSettingsRepositoryImpl implements UserSettingsRepository {
  UserSettingsRepositoryImpl(this._remote);

  final UserSettingsRemoteDataSource _remote;

  @override
  Future<UserPreferences> getSettings() async {
    return _map(await _remote.getSettings());
  }

  @override
  Future<UserPreferences> updateSettings(Map<String, dynamic> patch) async {
    return _map(await _remote.updateSettings(patch));
  }

  UserPreferences _map(UserPreferencesDto dto) {
    return UserPreferences(dto.toJson());
  }
}
