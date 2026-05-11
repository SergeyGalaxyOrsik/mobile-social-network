import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mobile_social_network/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:mobile_social_network/features/auth/presentation/bloc/auth_event.dart';
import 'package:mobile_social_network/features/chat/presentation/chat_navigation.dart';
import 'package:mobile_social_network/features/reference/domain/entities/reference_entities.dart';
import 'package:mobile_social_network/features/reference/domain/repositories/reference_repository.dart';
import 'package:mobile_social_network/features/user_settings/domain/entities/user_preferences.dart';
import 'package:mobile_social_network/features/user_settings/domain/repositories/user_settings_repository.dart';
import 'package:mobile_social_network/core/theme/locale_scope.dart';
import 'package:mobile_social_network/core/theme/theme_mode_scope.dart';
import 'package:mobile_social_network/l10n/app_localizations.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _loaded = false;
  bool _loading = true;
  bool _saving = false;
  String? _error;
  UserPreferences? _settings;
  List<AppLanguage> _languages = const [];
  List<AppThemeReference> _themes = const [];
  List<City> _cities = const [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loaded) {
      _loaded = true;
      _loadRemoteSettings();
    }
  }

  Future<void> _loadRemoteSettings() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final reference = context.read<ReferenceRepository>();
      final settingsRepo = context.read<UserSettingsRepository>();
      final results = await Future.wait<Object>([
        settingsRepo.getSettings(),
        reference.getLanguages(),
        reference.getThemes(),
        reference.getCities(limit: 100),
      ]);
      if (!mounted) return;
      setState(() {
        _settings = results[0] as UserPreferences;
        _languages = results[1] as List<AppLanguage>;
        _themes = results[2] as List<AppThemeReference>;
        _cities = results[3] as List<City>;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _patchSetting(Map<String, dynamic> patch) async {
    if (_saving) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final updated = await context
          .read<UserSettingsRepository>()
          .updateSettings(patch);
      if (!mounted) return;
      setState(() {
        _settings = updated;
        _saving = false;
      });
      _syncLocalShellSettings(patch);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _saving = false;
      });
    }
  }

  void _syncLocalShellSettings(Map<String, dynamic> patch) {
    final theme = patch['theme'] as String?;
    if (theme != null) {
      final mode = switch (theme.toLowerCase()) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      };
      ThemeModeScope.of(context).setThemeMode(mode);
    }
    final language = patch['language'] as String?;
    if (language != null) {
      LocaleScope.of(
        context,
      ).setLocale(language == 'system' ? null : Locale(language));
    }
  }

  List<DropdownMenuItem<String>> _items(Iterable<String> values) {
    return values
        .where((e) => e.trim().isNotEmpty)
        .map((e) => DropdownMenuItem<String>(value: e, child: Text(e)))
        .toList();
  }

  String? _selectedString(String? value, Iterable<String> allowed) {
    if (value == null || value.isEmpty) return null;
    return allowed.contains(value) ? value : null;
  }

  Widget _serverSettingsSection(BuildContext context) {
    final settings = _settings;
    final theme = Theme.of(context);
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Server preferences', style: theme.textTheme.titleMedium),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(_error!, style: TextStyle(color: theme.colorScheme.error)),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: _loadRemoteSettings,
                child: const Text('Retry'),
              ),
            ),
          ],
          const SizedBox(height: 8),
          Builder(
            builder: (context) {
              final themeCodes = _themes.isEmpty
                  ? const ['system', 'light', 'dark']
                  : _themes.map((e) => e.code).toList();
              return DropdownButtonFormField<String>(
                initialValue: _selectedString(settings?.theme, themeCodes),
                decoration: const InputDecoration(labelText: 'Theme'),
                items: _items(themeCodes),
                onChanged: _saving || settings == null
                    ? null
                    : (v) => v == null ? null : _patchSetting({'theme': v}),
              );
            },
          ),
          const SizedBox(height: 12),
          Builder(
            builder: (context) {
              final languageCodes = _languages.isEmpty
                  ? const ['system', 'ru', 'en']
                  : ['system', ..._languages.map((e) => e.code)];
              return DropdownButtonFormField<String>(
                initialValue: _selectedString(
                  settings?.language,
                  languageCodes,
                ),
                decoration: const InputDecoration(labelText: 'Language'),
                items: _items(languageCodes),
                onChanged: _saving || settings == null
                    ? null
                    : (v) => v == null ? null : _patchSetting({'language': v}),
              );
            },
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _selectedString(settings?.profileVisibility, const [
              'public',
              'private',
              'followers',
            ]),
            decoration: const InputDecoration(labelText: 'Profile visibility'),
            items: _items(const ['public', 'private', 'followers']),
            onChanged: _saving || settings == null
                ? null
                : (v) => v == null
                      ? null
                      : _patchSetting({'profileVisibility': v}),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _selectedString(settings?.postsVisibility, const [
              'public',
              'private',
              'followers',
            ]),
            decoration: const InputDecoration(labelText: 'Default posts'),
            items: _items(const ['public', 'private', 'followers']),
            onChanged: _saving || settings == null
                ? null
                : (v) =>
                      v == null ? null : _patchSetting({'postsVisibility': v}),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _selectedString(settings?.messagesAllowed, const [
              'everyone',
              'friends',
              'none',
            ]),
            decoration: const InputDecoration(labelText: 'Messages'),
            items: _items(const ['everyone', 'friends', 'none']),
            onChanged: _saving || settings == null
                ? null
                : (v) =>
                      v == null ? null : _patchSetting({'messagesAllowed': v}),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<int?>(
            initialValue: _cities.any((city) => city.id == settings?.cityId)
                ? settings?.cityId
                : null,
            decoration: const InputDecoration(labelText: 'Home city'),
            items: [
              const DropdownMenuItem<int?>(value: null, child: Text('Not set')),
              ..._cities.map(
                (city) => DropdownMenuItem<int?>(
                  value: city.id,
                  child: Text(city.name),
                ),
              ),
            ],
            onChanged: _saving || settings == null
                ? null
                : (v) => _patchSetting({'cityId': v}),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeScope = ThemeModeScope.of(context);
    final localeScope = LocaleScope.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Text(
              l10n.theme,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
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
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
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
          const Divider(height: 32),
          _serverSettingsSection(context),
          const Divider(height: 32),
          ListTile(
            title: Text(l10n.chatBlockedUsersTitle),
            leading: const Icon(Icons.block),
            onTap: () => pushChatBlocksPage(context),
          ),
          ListTile(
            title: const Text('Notifications'),
            leading: const Icon(Icons.notifications_outlined),
            onTap: () => Navigator.of(context).pushNamed('/notifications'),
          ),
          ListTile(
            title: const Text('Drafts'),
            leading: const Icon(Icons.drafts_outlined),
            onTap: () => Navigator.of(context).pushNamed('/drafts'),
          ),
          ListTile(
            title: const Text('Saved posts'),
            leading: const Icon(Icons.bookmarks_outlined),
            onTap: () => Navigator.of(context).pushNamed('/saved-posts'),
          ),
          ListTile(
            title: Text(l10n.logout),
            leading: const Icon(Icons.logout),
            onTap: () {
              context.read<AuthBloc>().add(const AuthSignOutRequested());
            },
          ),
        ],
      ),
    );
  }
}
