/// Общие константы приложения.
abstract class AppConstants {
  AppConstants._();

  /// Ключ сохранения режима темы (light / dark / system).
  static const String themeModeKey = 'theme_mode';

  /// Ключ сохранения языка (ru / en или пусто = по системе).
  static const String localeKey = 'locale';
}
