import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mobile_social_network/core/network/internet_connectivity_cubit.dart';
import 'package:mobile_social_network/core/network/internet_connectivity_state.dart';
import 'package:mobile_social_network/core/widgets/connectivity_banner.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mobile_social_network/core/config/current_app_config.dart';
import 'package:mobile_social_network/core/constants/app_constants.dart';
import 'package:mobile_social_network/core/network/app_dio.dart';
import 'package:mobile_social_network/core/network/s3_presigned_dio.dart';
import 'package:mobile_social_network/features/media/data/datasources/media_remote_datasource.dart';
import 'package:mobile_social_network/features/media/data/media_upload_service.dart';
import 'package:mobile_social_network/core/theme/app_asset.dart';
import 'package:mobile_social_network/core/theme/locale_scope.dart';
import 'package:mobile_social_network/core/theme/theme_mode_scope.dart';
import 'package:mobile_social_network/l10n/app_localizations.dart';
import 'package:mobile_social_network/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:mobile_social_network/features/auth/data/repositories/auth_repository_remote_impl.dart';
import 'package:mobile_social_network/features/auth/data/repositories/user_repository_impl.dart';
import 'package:mobile_social_network/features/auth/domain/repositories/auth_repository.dart';
import 'package:mobile_social_network/features/auth/domain/repositories/user_repository.dart';
import 'package:mobile_social_network/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:mobile_social_network/features/auth/presentation/bloc/auth_event.dart';
import 'package:mobile_social_network/features/auth/presentation/bloc/auth_state.dart';
import 'package:mobile_social_network/features/auth/presentation/pages/login_page.dart';
import 'package:mobile_social_network/features/feed/presentation/cubit/feed_cubit.dart';
import 'package:mobile_social_network/features/main/presentation/pages/main_page.dart';
import 'package:mobile_social_network/features/posts/data/datasources/feed_cache_datasource.dart';
import 'package:mobile_social_network/features/posts/data/datasources/posts_engagement_remote_datasource.dart';
import 'package:mobile_social_network/features/posts/data/datasources/posts_remote_datasource.dart';
import 'package:mobile_social_network/features/posts/data/repositories/post_engagement_repository_impl.dart';
import 'package:mobile_social_network/features/posts/data/repositories/post_local_repository_impl.dart';
import 'package:mobile_social_network/features/posts/data/repositories/post_repository_impl.dart';
import 'package:mobile_social_network/features/posts/domain/repositories/post_engagement_repository.dart';
import 'package:mobile_social_network/features/posts/domain/repositories/post_repository.dart';
import 'package:mobile_social_network/features/posts/presentation/pages/create_post_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: WidgetsBinding.instance);
  MyApp.splashStartedAt = DateTime.now();

  final preferences = await SharedPreferences.getInstance();
  final appConfig = resolveAppConfig();
  if (kDebugMode) {
    debugPrint(
      '[AppConfig] ${appConfig.environmentLabel} baseUrl=${appConfig.apiBaseUrl} '
      'presignedOrigin=${appConfig.presignedUploadOrigin.isEmpty ? '(default from API)' : appConfig.presignedUploadOrigin}',
    );
  }

  final dio = createAppDio(appConfig: appConfig, preferences: preferences);
  final authRemote = AuthRemoteDataSource(dio);
  final postsRemote = PostsRemoteDataSource(dio);
  final postsEngagementRemote = PostsEngagementRemoteDataSource(dio);
  final PostEngagementRepository postEngagementRepository =
      PostEngagementRepositoryImpl(postsEngagementRemote);
  final s3Dio = createS3PresignedDio();
  final mediaRemote = MediaRemoteDataSource(dio);
  final mediaUploadService = MediaUploadService(
    api: mediaRemote,
    s3Dio: s3Dio,
    presignedUploadOrigin: appConfig.presignedUploadOrigin,
  );

  final UserRepository userRepository = UserRepositoryImpl();
  final AuthRepository authRepository = AuthRepositoryRemoteImpl(
    remote: authRemote,
    preferences: preferences,
  );
  final postLocal = PostLocalRepositoryImpl();
  final feedCache = FeedCacheDataSource();
  final PostRepository postRepository = PostRepositoryImpl(
    remote: postsRemote,
    local: postLocal,
    feedCache: feedCache,
  );
  final authBloc = AuthBloc(authRepository: authRepository);

  runApp(MyApp(
    authBloc: authBloc,
    preferences: preferences,
    userRepository: userRepository,
    postRepository: postRepository,
    postEngagementRepository: postEngagementRepository,
    mediaUploadService: mediaUploadService,
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({
    super.key,
    required this.authBloc,
    required this.preferences,
    required this.userRepository,
    required this.postRepository,
    required this.postEngagementRepository,
    required this.mediaUploadService,
  });

  final AuthBloc authBloc;
  final SharedPreferences preferences;
  final UserRepository userRepository;
  final PostRepository postRepository;
  final PostEngagementRepository postEngagementRepository;
  final MediaUploadService mediaUploadService;

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
      child: BlocProvider<InternetConnectivityCubit>(
        create: (_) => InternetConnectivityCubit(),
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
              builder: (context, child) {
                return BlocBuilder<InternetConnectivityCubit, InternetConnectivityState>(
                  buildWhen: (previous, current) =>
                      previous.showOfflineBanner != current.showOfflineBanner,
                  builder: (context, state) {
                    return Stack(
                      fit: StackFit.expand,
                      children: [
                        child ?? const SizedBox.shrink(),
                        if (state.showOfflineBanner)
                          const Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            child: ConnectivityBanner(),
                          ),
                      ],
                    );
                  },
                );
              },
              home: _AuthGate(
                userRepository: widget.userRepository,
                postRepository: widget.postRepository,
                postEngagementRepository: widget.postEngagementRepository,
                mediaUploadService: widget.mediaUploadService,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Проверяет авторизацию: при старте запрашивает CheckAuth,
/// показывает Login или Main в зависимости от состояния.
class _AuthGate extends StatefulWidget {
  const _AuthGate({
    required this.userRepository,
    required this.postRepository,
    required this.postEngagementRepository,
    required this.mediaUploadService,
  });

  final UserRepository userRepository;
  final PostRepository postRepository;
  final PostEngagementRepository postEngagementRepository;
  final MediaUploadService mediaUploadService;

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
          final user = state.user;
          return RepositoryProvider<UserRepository>.value(
            value: widget.userRepository,
            child: RepositoryProvider<PostRepository>.value(
              value: widget.postRepository,
              child: RepositoryProvider<PostEngagementRepository>.value(
                value: widget.postEngagementRepository,
                child: BlocProvider<FeedCubit>(
                  create: (context) => FeedCubit(
                    postRepository: context.read<PostRepository>(),
                    postEngagementRepository:
                        context.read<PostEngagementRepository>(),
                    mediaUploadService: widget.mediaUploadService,
                  ),
              child: Navigator(
                onGenerateInitialRoutes: (_, __) => [
                  MaterialPageRoute<void>(
                    builder: (_) => MainPage(user: user),
                  ),
                ],
                onGenerateRoute: (settings) {
                  if (settings.name == '/create') {
                    return MaterialPageRoute<void>(
                      builder: (_) => const CreatePostPage(),
                    );
                  }
                  return null;
                },
                ),
              ),
            ),
          ),
          );
        }
        if (state is AuthUnauthenticated || state is AuthError) {
          return const LoginPage();
        }
        
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }
}
