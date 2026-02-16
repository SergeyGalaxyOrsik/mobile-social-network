import 'package:flutter/material.dart';

import 'package:mobile_social_network/core/theme/locale_scope.dart';
import 'package:mobile_social_network/core/theme/theme_mode_scope.dart';
import 'package:mobile_social_network/l10n/app_localizations.dart';

/// Экран настроек: выбор темы и языка.
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeScope = ThemeModeScope.of(context);
    final localeScope = LocaleScope.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Text(
              l10n.theme,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          RadioListTile<ThemeMode>(
            title: Text(l10n.themeLight),
            value: ThemeMode.light,
            groupValue: themeScope.themeMode,
            onChanged: (_) => themeScope.setThemeMode(ThemeMode.light),
          ),
          RadioListTile<ThemeMode>(
            title: Text(l10n.themeDark),
            value: ThemeMode.dark,
            groupValue: themeScope.themeMode,
            onChanged: (_) => themeScope.setThemeMode(ThemeMode.dark),
          ),
          RadioListTile<ThemeMode>(
            title: Text(l10n.themeSystem),
            value: ThemeMode.system,
            groupValue: themeScope.themeMode,
            onChanged: (_) => themeScope.setThemeMode(ThemeMode.system),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Text(
              l10n.language,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          RadioListTile<Locale?>(
            title: Text(l10n.languageSystem),
            value: null,
            groupValue: localeScope.locale,
            onChanged: (_) => localeScope.setLocale(null),
          ),
          RadioListTile<Locale?>(
            title: Text(l10n.languageRu),
            value: const Locale('ru'),
            groupValue: localeScope.locale,
            onChanged: (_) => localeScope.setLocale(const Locale('ru')),
          ),
          RadioListTile<Locale?>(
            title: Text(l10n.languageEn),
            value: const Locale('en'),
            groupValue: localeScope.locale,
            onChanged: (_) => localeScope.setLocale(const Locale('en')),
          ),
        ],
      ),
    );
  }
}
