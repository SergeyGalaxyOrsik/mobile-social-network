import 'package:flutter/material.dart';

import 'package:mobile_social_network/core/theme/theme_mode_scope.dart';

/// Экран настроек: выбор темы (светлая / тёмная / как в системе).
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final scope = ThemeModeScope.of(context);
    final themeMode = scope.themeMode;
    final setThemeMode = scope.setThemeMode;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Настройки'),
      ),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Text(
              'Тема',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          RadioListTile<ThemeMode>(
            title: const Text('Светлая'),
            value: ThemeMode.light,
            groupValue: themeMode,
            onChanged: (_) => setThemeMode(ThemeMode.light),
          ),
          RadioListTile<ThemeMode>(
            title: const Text('Тёмная'),
            value: ThemeMode.dark,
            groupValue: themeMode,
            onChanged: (_) => setThemeMode(ThemeMode.dark),
          ),
          RadioListTile<ThemeMode>(
            title: const Text('Как в системе'),
            value: ThemeMode.system,
            groupValue: themeMode,
            onChanged: (_) => setThemeMode(ThemeMode.system),
          ),
        ],
      ),
    );
  }
}
