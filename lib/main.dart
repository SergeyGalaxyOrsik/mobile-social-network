import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mobile_social_network/core/constants/app_constants.dart';
import 'package:mobile_social_network/core/theme/app_asset.dart';
import 'package:mobile_social_network/core/theme/locale_scope.dart';
import 'package:mobile_social_network/core/theme/theme_mode_scope.dart';
import 'package:mobile_social_network/l10n/app_localizations.dart';
import 'package:mobile_social_network/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:mobile_social_network/features/auth/data/repositories/user_repository_impl.dart';
import 'package:mobile_social_network/features/auth/domain/repositories/auth_repository.dart';
import 'package:mobile_social_network/features/auth/domain/repositories/user_repository.dart';
import 'package:mobile_social_network/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:mobile_social_network/features/auth/presentation/bloc/auth_event.dart';
import 'package:mobile_social_network/features/auth/presentation/bloc/auth_state.dart';
import 'package:mobile_social_network/features/auth/presentation/pages/login_page.dart';
import 'package:mobile_social_network/features/main/presentation/pages/main_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: WidgetsBinding.instance);
  MyApp.splashStartedAt = DateTime.now();

  final preferences = await SharedPreferences.getInstance();
  final UserRepository userRepository = UserRepositoryImpl();
  final AuthRepository authRepository = AuthRepositoryImpl(
    userRepository: userRepository,
    preferences: preferences,
  );
  final authBloc = AuthBloc(authRepository: authRepository);

  runApp(MyApp(authBloc: authBloc, preferences: preferences));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key, required this.authBloc, required this.preferences});

  final AuthBloc authBloc;
  final SharedPreferences preferences;

  static DateTime? splashStartedAt;

  static const _splashMinDuration = Duration(seconds: 5);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late ThemeMode _themeMode;
  Locale? _locale;

  @override
  void initState() {
    super.initState();
    _themeMode = _loadThemeMode(widget.preferences);
    _locale = _loadLocale(widget.preferences);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final elapsed = DateTime.now().difference(
        MyApp.splashStartedAt ?? DateTime.now(),
      );
      final remaining = MyApp._splashMinDuration - elapsed;
      if (remaining > Duration.zero) {
        await Future.delayed(remaining);
      }
      FlutterNativeSplash.remove();
    });
  }

  static ThemeMode _loadThemeMode(SharedPreferences prefs) {
    final value = prefs.getString(AppConstants.themeModeKey);
    if (value == null) return ThemeMode.system;
    return switch (value) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  static Locale? _loadLocale(SharedPreferences prefs) {
    final code = prefs.getString(AppConstants.localeKey);
    if (code == null || code.isEmpty) return null;
    return Locale(code);
  }

  void _setLocale(Locale? locale) {
    setState(() => _locale = locale);
    if (locale != null) {
      widget.preferences.setString(AppConstants.localeKey, locale.languageCode);
    } else {
      widget.preferences.remove(AppConstants.localeKey);
    }
  }

  void _setThemeMode(ThemeMode mode) {
    setState(() => _themeMode = mode);
    widget.preferences.setString(AppConstants.themeModeKey, switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthBloc>.value(
      value: widget.authBloc,
      child: ThemeModeScope(
        themeMode: _themeMode,
        setThemeMode: _setThemeMode,
        child: LocaleScope(
          locale: _locale,
          setLocale: _setLocale,
          child: MaterialApp(
            title: _locale?.languageCode == 'en' ? 'Social Network' : 'Социальная сеть',
            theme: AppAsset.themeLight,
            darkTheme: AppAsset.themeDark,
            themeMode: _themeMode,
            locale: _locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const _AuthGate(),
          ),
        ),
      ),
    );
  }
}

/// Проверяет авторизацию: при старте запрашивает CheckAuth,
/// показывает Login или Main в зависимости от состояния.
class _AuthGate extends StatefulWidget {
  const _AuthGate();

  @override
  State<_AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<_AuthGate> {
  @override
  void initState() {
    super.initState();
    context.read<AuthBloc>().add(const AuthCheckRequested());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthAuthenticated) {
          return MainPage(user: state.user);
        }
        if (state is AuthUnauthenticated || state is AuthError) {
          return const LoginPage();
        }
        // AuthInitial или AuthLoading — пока сплэш или загрузка
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }
}
