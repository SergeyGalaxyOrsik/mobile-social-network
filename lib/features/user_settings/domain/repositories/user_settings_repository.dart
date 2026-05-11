import 'package:mobile_social_network/features/user_settings/domain/entities/user_preferences.dart';

abstract class UserSettingsRepository {
  Future<UserPreferences> getSettings();

  Future<UserPreferences> updateSettings(Map<String, dynamic> patch);
}
