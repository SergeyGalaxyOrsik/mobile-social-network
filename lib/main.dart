import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mobile_social_network/core/navigation/app_navigator_keys.dart';
import 'package:mobile_social_network/core/notifications/fcm_setup.dart';
import 'package:mobile_social_network/core/notifications/push_lifecycle_host.dart';
import 'package:mobile_social_network/core/network/internet_connectivity_cubit.dart';
import 'package:mobile_social_network/core/network/internet_connectivity_state.dart';
import 'package:mobile_social_network/core/widgets/connectivity_banner.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mobile_social_network/core/config/current_app_config.dart';
import 'package:mobile_social_network/core/config/media_url_rewrite_config.dart';
import 'package:mobile_social_network/core/constants/app_constants.dart';
import 'package:mobile_social_network/core/network/app_dio.dart';
import 'package:mobile_social_network/core/network/chat_socket_uri.dart';
import 'package:mobile_social_network/core/network/s3_presigned_dio.dart';
import 'package:mobile_social_network/features/chat/data/datasources/chat_remote_datasource.dart';
import 'package:mobile_social_network/features/chat/data/datasources/chat_socket_client.dart';
import 'package:mobile_social_network/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:mobile_social_network/features/chat/domain/repositories/chat_repository.dart';
import 'package:mobile_social_network/features/chat/presentation/chat_navigation.dart';
import 'package:mobile_social_network/features/chat/presentation/pages/chat_blocks_page.dart';
import 'package:mobile_social_network/features/chat/presentation/pages/conversations_page.dart';
import 'package:mobile_social_network/features/chat/presentation/pages/direct_chat_page.dart';
import 'package:mobile_social_network/features/custom_tags/data/datasources/custom_tags_remote_datasource.dart';
import 'package:mobile_social_network/features/custom_tags/data/repositories/custom_tags_repository_impl.dart';
import 'package:mobile_social_network/features/custom_tags/domain/repositories/custom_tags_repository.dart';
import 'package:mobile_social_network/features/draft_posts/data/datasources/draft_posts_remote_datasource.dart';
import 'package:mobile_social_network/features/draft_posts/data/repositories/draft_posts_repository_impl.dart';
import 'package:mobile_social_network/features/draft_posts/domain/repositories/draft_posts_repository.dart';
import 'package:mobile_social_network/features/draft_posts/presentation/pages/draft_posts_page.dart';
import 'package:mobile_social_network/features/media/data/datasources/media_remote_datasource.dart';
import 'package:mobile_social_network/features/media/data/media_upload_service.dart';
import 'package:mobile_social_network/features/moderation/data/datasources/moderation_remote_datasource.dart';
import 'package:mobile_social_network/features/moderation/data/repositories/moderation_repository_impl.dart';
import 'package:mobile_social_network/features/moderation/domain/repositories/moderation_repository.dart';
import 'package:mobile_social_network/features/notifications/data/datasources/notifications_remote_datasource.dart';
import 'package:mobile_social_network/features/notifications/data/repositories/notifications_repository_impl.dart';
import 'package:mobile_social_network/features/notifications/domain/repositories/notifications_repository.dart';
import 'package:mobile_social_network/features/notifications/presentation/pages/notifications_page.dart';
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
import 'package:mobile_social_network/features/reference/data/datasources/reference_remote_datasource.dart';
import 'package:mobile_social_network/features/reference/data/repositories/reference_repository_impl.dart';
import 'package:mobile_social_network/features/reference/domain/repositories/reference_repository.dart';
import 'package:mobile_social_network/features/reports/data/datasources/reports_remote_datasource.dart';
import 'package:mobile_social_network/features/reports/data/repositories/reports_repository_impl.dart';
import 'package:mobile_social_network/features/reports/domain/repositories/reports_repository.dart';
import 'package:mobile_social_network/features/saved_posts/data/datasources/saved_posts_remote_datasource.dart';
import 'package:mobile_social_network/features/saved_posts/data/repositories/saved_posts_repository_impl.dart';
import 'package:mobile_social_network/features/saved_posts/domain/repositories/saved_posts_repository.dart';
import 'package:mobile_social_network/features/saved_posts/presentation/pages/saved_posts_page.dart';
import 'package:mobile_social_network/features/social_users/data/datasources/social_users_remote_datasource.dart';
import 'package:mobile_social_network/features/social_users/data/repositories/social_users_repository_impl.dart';
import 'package:mobile_social_network/features/social_users/domain/repositories/social_users_repository.dart';
import 'package:mobile_social_network/features/user_settings/data/datasources/user_settings_remote_datasource.dart';
import 'package:mobile_social_network/features/user_settings/data/repositories/user_settings_repository_impl.dart';
import 'package:mobile_social_network/features/user_settings/domain/repositories/user_settings_repository.dart';
import 'package:mobile_social_network/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  await setupFirebaseMessaging();
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

  Future<void> revokePushTokenOnServer() async {
    final token = await FirebaseMessaging.instance.getToken();
    if (token == null || token.isEmpty) {
      return;
    }
    try {
      await authRemote.deletePushToken(token);
    } catch (_) {}
  }

  final AuthRepository authRepository = AuthRepositoryRemoteImpl(
    remote: authRemote,
    preferences: preferences,
    revokePushOnSignOut: revokePushTokenOnServer,
  );
  final postLocal = PostLocalRepositoryImpl();
  final feedCache = FeedCacheDataSource();
  final PostRepository postRepository = PostRepositoryImpl(
    remote: postsRemote,
    local: postLocal,
    feedCache: feedCache,
  );
  final socialUsersRemote = SocialUsersRemoteDataSource(dio);
  final SocialUsersRepository socialUsersRepository = SocialUsersRepositoryImpl(
    socialUsersRemote,
  );
  final chatRemote = ChatRemoteDataSource(dio);
  final chatSocket = ChatSocketClient(
    socketUri: resolveChatSocketUri(appConfig.apiBaseUrl),
    accessToken: () => preferences.getString(AppConstants.accessTokenKey),
  );
  final ChatRepository chatRepository = ChatRepositoryImpl(
    remote: chatRemote,
    socket: chatSocket,
  );
  final ReferenceRepository referenceRepository = ReferenceRepositoryImpl(
    ReferenceRemoteDataSource(dio),
  );
  final UserSettingsRepository userSettingsRepository =
      UserSettingsRepositoryImpl(UserSettingsRemoteDataSource(dio));
  final DraftPostsRepository draftPostsRepository = DraftPostsRepositoryImpl(
    DraftPostsRemoteDataSource(dio),
  );
  final SavedPostsRepository savedPostsRepository = SavedPostsRepositoryImpl(
    SavedPostsRemoteDataSource(dio),
  );
  final CustomTagsRepository customTagsRepository = CustomTagsRepositoryImpl(
    CustomTagsRemoteDataSource(dio),
  );
  final NotificationsRepository notificationsRepository =
      NotificationsRepositoryImpl(NotificationsRemoteDataSource(dio));
  final ReportsRepository reportsRepository = ReportsRepositoryImpl(
    ReportsRemoteDataSource(dio),
  );
  final ModerationRepository moderationRepository = ModerationRepositoryImpl(
    ModerationRemoteDataSource(dio),
  );
  final authBloc = AuthBloc(authRepository: authRepository);
  final mediaUrlRewriteConfig = MediaUrlRewriteConfig(
    appConfig.presignedUploadOrigin,
  );

  runApp(
    MyApp(
      authBloc: authBloc,
      authRemote: authRemote,
      preferences: preferences,
      userRepository: userRepository,
      postRepository: postRepository,
      postEngagementRepository: postEngagementRepository,
      mediaUploadService: mediaUploadService,
      socialUsersRepository: socialUsersRepository,
      chatRepository: chatRepository,
      referenceRepository: referenceRepository,
      userSettingsRepository: userSettingsRepository,
      draftPostsRepository: draftPostsRepository,
      savedPostsRepository: savedPostsRepository,
      customTagsRepository: customTagsRepository,
      notificationsRepository: notificationsRepository,
      reportsRepository: reportsRepository,
      moderationRepository: moderationRepository,
      mediaUrlRewriteConfig: mediaUrlRewriteConfig,
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({
    super.key,
    required this.authBloc,
    required this.authRemote,
    required this.preferences,
    required this.userRepository,
    required this.postRepository,
    required this.postEngagementRepository,
    required this.mediaUploadService,
    required this.socialUsersRepository,
    required this.chatRepository,
    required this.referenceRepository,
    required this.userSettingsRepository,
    required this.draftPostsRepository,
    required this.savedPostsRepository,
    required this.customTagsRepository,
    required this.notificationsRepository,
    required this.reportsRepository,
    required this.moderationRepository,
    required this.mediaUrlRewriteConfig,
  });

  final AuthBloc authBloc;
  final AuthRemoteDataSource authRemote;
  final SharedPreferences preferences;
  final UserRepository userRepository;
  final PostRepository postRepository;
  final PostEngagementRepository postEngagementRepository;
  final MediaUploadService mediaUploadService;
  final SocialUsersRepository socialUsersRepository;
  final ChatRepository chatRepository;
  final ReferenceRepository referenceRepository;
  final UserSettingsRepository userSettingsRepository;
  final DraftPostsRepository draftPostsRepository;
  final SavedPostsRepository savedPostsRepository;
  final CustomTagsRepository customTagsRepository;
  final NotificationsRepository notificationsRepository;
  final ReportsRepository reportsRepository;
  final ModerationRepository moderationRepository;
  final MediaUrlRewriteConfig mediaUrlRewriteConfig;

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
    return RepositoryProvider<MediaUrlRewriteConfig>.value(
      value: widget.mediaUrlRewriteConfig,
      child: BlocProvider<AuthBloc>.value(
        value: widget.authBloc,
        child: RepositoryProvider<ChatRepository>.value(
          value: widget.chatRepository,
          child: BlocListener<AuthBloc, AuthState>(
            listenWhen: (previous, current) =>
                previous is AuthAuthenticated != current is AuthAuthenticated,
            listener: (context, state) {
              final chat = context.read<ChatRepository>();
              if (state is AuthAuthenticated) {
                unawaited(chat.activateRealtime());
              } else {
                chat.deactivateRealtime();
              }
            },
            child: BlocProvider<InternetConnectivityCubit>(
              create: (_) => InternetConnectivityCubit(),
              child: ThemeModeScope(
                themeMode: _themeMode,
                setThemeMode: _setThemeMode,
                child: LocaleScope(
                  locale: _locale,
                  setLocale: _setLocale,
                  child: MaterialApp(
                    navigatorKey: appRootNavigatorKey,
                    scaffoldMessengerKey: appRootMessengerKey,
                    title: _locale?.languageCode == 'en'
                        ? 'Social Network'
                        : 'Социальная сеть',
                    theme: AppAsset.themeLight,
                    darkTheme: AppAsset.themeDark,
                    themeMode: _themeMode,
                    locale: _locale,
                    localizationsDelegates:
                        AppLocalizations.localizationsDelegates,
                    supportedLocales: AppLocalizations.supportedLocales,
                    builder: (context, child) {
                      return PushLifecycleHost(
                        authRemote: widget.authRemote,
                        child:
                            BlocBuilder<
                              InternetConnectivityCubit,
                              InternetConnectivityState
                            >(
                              buildWhen: (previous, current) =>
                                  previous.showOfflineBanner !=
                                  current.showOfflineBanner,
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
                            ),
                      );
                    },
                    home: _AuthGate(
                      userRepository: widget.userRepository,
                      postRepository: widget.postRepository,
                      postEngagementRepository: widget.postEngagementRepository,
                      mediaUploadService: widget.mediaUploadService,
                      socialUsersRepository: widget.socialUsersRepository,
                      referenceRepository: widget.referenceRepository,
                      userSettingsRepository: widget.userSettingsRepository,
                      draftPostsRepository: widget.draftPostsRepository,
                      savedPostsRepository: widget.savedPostsRepository,
                      customTagsRepository: widget.customTagsRepository,
                      notificationsRepository: widget.notificationsRepository,
                      reportsRepository: widget.reportsRepository,
                      moderationRepository: widget.moderationRepository,
                    ),
                  ),
                ),
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
    required this.socialUsersRepository,
    required this.referenceRepository,
    required this.userSettingsRepository,
    required this.draftPostsRepository,
    required this.savedPostsRepository,
    required this.customTagsRepository,
    required this.notificationsRepository,
    required this.reportsRepository,
    required this.moderationRepository,
  });

  final UserRepository userRepository;
  final PostRepository postRepository;
  final PostEngagementRepository postEngagementRepository;
  final MediaUploadService mediaUploadService;
  final SocialUsersRepository socialUsersRepository;
  final ReferenceRepository referenceRepository;
  final UserSettingsRepository userSettingsRepository;
  final DraftPostsRepository draftPostsRepository;
  final SavedPostsRepository savedPostsRepository;
  final CustomTagsRepository customTagsRepository;
  final NotificationsRepository notificationsRepository;
  final ReportsRepository reportsRepository;
  final ModerationRepository moderationRepository;

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
              child: RepositoryProvider<SocialUsersRepository>.value(
                value: widget.socialUsersRepository,
                child: RepositoryProvider<ReferenceRepository>.value(
                  value: widget.referenceRepository,
                  child: RepositoryProvider<UserSettingsRepository>.value(
                    value: widget.userSettingsRepository,
                    child: RepositoryProvider<DraftPostsRepository>.value(
                      value: widget.draftPostsRepository,
                      child: RepositoryProvider<SavedPostsRepository>.value(
                        value: widget.savedPostsRepository,
                        child: RepositoryProvider<CustomTagsRepository>.value(
                          value: widget.customTagsRepository,
                          child: RepositoryProvider<NotificationsRepository>.value(
                            value: widget.notificationsRepository,
                            child: RepositoryProvider<ReportsRepository>.value(
                              value: widget.reportsRepository,
                              child: RepositoryProvider<ModerationRepository>.value(
                                value: widget.moderationRepository,
                                child: RepositoryProvider<PostEngagementRepository>.value(
                                  value: widget.postEngagementRepository,
                                  child:
                                      RepositoryProvider<
                                        MediaUploadService
                                      >.value(
                                        value: widget.mediaUploadService,
                                        child: BlocProvider<FeedCubit>(
                                          create: (context) => FeedCubit(
                                            postRepository: context
                                                .read<PostRepository>(),
                                            postEngagementRepository: context
                                                .read<
                                                  PostEngagementRepository
                                                >(),
                                            mediaUploadService:
                                                widget.mediaUploadService,
                                          ),
                                          child: Navigator(
                                            key: appShellNavigatorKey,
                                            onGenerateInitialRoutes: (_, __) =>
                                                [
                                                  MaterialPageRoute<void>(
                                                    builder: (_) =>
                                                        MainPage(user: user),
                                                  ),
                                                ],
                                            onGenerateRoute: (settings) {
                                              if (settings.name == '/create') {
                                                return MaterialPageRoute<void>(
                                                  builder: (_) =>
                                                      const CreatePostPage(),
                                                );
                                              }
                                              if (settings.name == '/drafts') {
                                                return MaterialPageRoute<void>(
                                                  builder: (_) =>
                                                      const DraftPostsPage(),
                                                );
                                              }
                                              if (settings.name ==
                                                  '/saved-posts') {
                                                return MaterialPageRoute<void>(
                                                  builder: (_) =>
                                                      const SavedPostsPage(),
                                                );
                                              }
                                              if (settings.name ==
                                                  '/notifications') {
                                                return MaterialPageRoute<void>(
                                                  builder: (_) =>
                                                      const NotificationsPage(),
                                                );
                                              }
                                              if (settings.name ==
                                                  '/conversations') {
                                                return MaterialPageRoute<void>(
                                                  builder: (_) =>
                                                      const ConversationsPage(),
                                                );
                                              }
                                              if (settings.name == '/chat') {
                                                final args = settings.arguments;
                                                if (args
                                                    is! DirectChatRouteArgs) {
                                                  return null;
                                                }
                                                return MaterialPageRoute<void>(
                                                  builder: (_) =>
                                                      DirectChatPage(
                                                        args: args,
                                                      ),
                                                );
                                              }
                                              if (settings.name ==
                                                  '/chat/blocks') {
                                                return MaterialPageRoute<void>(
                                                  builder: (_) =>
                                                      const ChatBlocksPage(),
                                                );
                                              }
                                              return null;
                                            },
                                          ),
                                        ),
                                      ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
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
