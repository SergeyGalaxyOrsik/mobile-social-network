import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mobile_social_network/core/notifications/push_main_intent.dart';
import 'package:mobile_social_network/features/auth/domain/entities/user_entity.dart';
import 'package:mobile_social_network/features/feed/presentation/cubit/feed_cubit.dart';
import 'package:mobile_social_network/features/feed/presentation/pages/feed_page.dart';
import 'package:mobile_social_network/features/main/presentation/pages/settings_page.dart';
import 'package:mobile_social_network/features/social_users/domain/repositories/social_users_repository.dart';
import 'package:mobile_social_network/features/social_users/presentation/cubit/friend_requests_cubit.dart';
import 'package:mobile_social_network/features/social_users/presentation/cubit/friends_list_cubit.dart';
import 'package:mobile_social_network/features/social_users/presentation/cubit/user_profile_cubit.dart';
import 'package:mobile_social_network/features/social_users/presentation/cubit/user_search_cubit.dart';
import 'package:mobile_social_network/features/chat/presentation/chat_navigation.dart';
import 'package:mobile_social_network/features/social_users/presentation/pages/friends_tab_page.dart';
import 'package:mobile_social_network/features/social_users/presentation/pages/user_profile_page.dart';
import 'package:mobile_social_network/l10n/app_localizations.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key, required this.user});

  final UserEntity user;

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;
  int _friendsTabIndex = 0;
  String? _incomingRequestHighlightId;
  /// Контекст под [MultiBlocProvider] (доступ к [FriendRequestsCubit]).
  BuildContext? _friendsScopedContext;

  @override
  void initState() {
    super.initState();
    PushMainIntentBus.pending.addListener(_onPushMainIntent);
  }

  @override
  void dispose() {
    PushMainIntentBus.pending.removeListener(_onPushMainIntent);
    super.dispose();
  }

  void _onPushMainIntent() {
    final intent = PushMainIntentBus.pending.value;
    if (intent == null) {
      return;
    }
    PushMainIntentBus.pending.value = null;
    if (!mounted) {
      return;
    }
    setState(() {
      if (intent.selectedTabIndex != null) {
        _selectedIndex = intent.selectedTabIndex!;
      }
      if (intent.friendsTabIndex != null) {
        _friendsTabIndex = intent.friendsTabIndex!;
      }
      if (intent.resetFriendRequestHighlight) {
        _incomingRequestHighlightId = null;
      }
      if (intent.highlightIncomingRequestId != null) {
        _incomingRequestHighlightId = intent.highlightIncomingRequestId;
      }
    });
    if (intent.refreshFeed) {
      context.read<FeedCubit>().loadNotes(currentUser: widget.user);
    }
    if (intent.reloadFriendRequests) {
      final friendsCtx = _friendsScopedContext;
      if (friendsCtx != null && friendsCtx.mounted) {
        friendsCtx.read<FriendRequestsCubit>().load();
        friendsCtx.read<FriendsListCubit>().load();
      }
    }
  }

  static Color _navBarSurfaceColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Theme.of(context).colorScheme.surface
        : Colors.transparent;
  }

  Widget _buildHomeContent(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) => [
        SliverToBoxAdapter(
          child: SafeArea(
            bottom: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 24, right: 24, top: 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          l10n.helloUser(
                            widget.user.username ?? widget.user.email,
                          ),
                          style: Theme.of(context).textTheme.displayMedium,
                          textAlign: TextAlign.left,
                        ),
                      ),
                      IconButton(
                        tooltip: l10n.chatConversationsTitle,
                        onPressed: () => pushConversationsPage(context),
                        icon: const Icon(Icons.forum_outlined),
                      ),
                    ],
                  ),
                ),
                Divider(
                  height: 2,
                  thickness: 2,
                  color: Theme.of(context).colorScheme.outline,
                ),
              ],
            ),
          ),
        ),
      ],
      body: const FeedPage(),
    );
  }

  void _openCreatePost(BuildContext context) {
    Navigator.of(context).pushNamed('/create');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;

    return MultiBlocProvider(
      providers: [
        BlocProvider<FriendRequestsCubit>(
          create: (c) => FriendRequestsCubit(
            c.read<SocialUsersRepository>(),
          ),
        ),
        BlocProvider<FriendsListCubit>(
          create: (c) => FriendsListCubit(
            c.read<SocialUsersRepository>(),
          ),
        ),
        BlocProvider<UserSearchCubit>(
          create: (c) => UserSearchCubit(c.read<SocialUsersRepository>()),
        ),
      ],
      child: Builder(
        builder: (scopedContext) {
          _friendsScopedContext = scopedContext;
          return Scaffold(
            body: IndexedStack(
              index: _selectedIndex,
              children: [
                _buildHomeContent(scopedContext),
                FriendsTabPage(
                  initialFriendsTabIndex: _friendsTabIndex,
                  highlightIncomingRequestId: _incomingRequestHighlightId,
                ),
                BlocProvider<UserProfileCubit>(
                  create: (c) => UserProfileCubit(
                    c.read<SocialUsersRepository>(),
                    widget.user.id,
                  ),
                  child: UserProfilePage(profileUserId: widget.user.id),
                ),
                const SettingsPage(),
              ],
            ),
            floatingActionButton: _selectedIndex == 0
                ? FloatingActionButton(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    onPressed: () => _openCreatePost(scopedContext),
                    child: const Icon(Icons.add),
                  )
                : null,
            bottomNavigationBar: SafeArea(
              top: false,
              left: false,
              right: false,
              child: Container(
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: Colors.black, width: 1)),
                ),
                padding: const EdgeInsets.only(top: 8),
                child: Theme(
                  data: Theme.of(scopedContext).copyWith(
                    colorScheme: Theme.of(
                      scopedContext,
                    ).colorScheme.copyWith(
                      surface: _navBarSurfaceColor(scopedContext),
                    ),
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    splashFactory: NoSplash.splashFactory,
                    navigationBarTheme: const NavigationBarThemeData(
                      surfaceTintColor: Colors.transparent,
                      indicatorColor: Colors.transparent,
                    ),
                  ),
                  child: NavigationBar(
                    selectedIndex: _selectedIndex,
                    onDestinationSelected: (index) {
                      setState(() => _selectedIndex = index);
                      if (index == 1) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (!scopedContext.mounted) {
                            return;
                          }
                          scopedContext.read<FriendRequestsCubit>().load();
                          scopedContext.read<FriendsListCubit>().load();
                        });
                      }
                    },
                    backgroundColor: _navBarSurfaceColor(scopedContext),
                    surfaceTintColor: Colors.transparent,
                    elevation: 0,
                    labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
                    destinations: [
                      NavigationDestination(
                        icon: Icon(
                          Icons.home_outlined,
                          color: scheme.onSurfaceVariant,
                          size: 24,
                        ),
                        selectedIcon: Icon(
                          Icons.home,
                          color: scheme.primary,
                          size: 24,
                        ),
                        label: l10n.home,
                      ),
                      NavigationDestination(
                        icon: Icon(
                          Icons.group_outlined,
                          color: scheme.onSurfaceVariant,
                          size: 24,
                        ),
                        selectedIcon: Icon(
                          Icons.group,
                          color: scheme.primary,
                          size: 24,
                        ),
                        label: l10n.mainNavFriends,
                      ),
                      NavigationDestination(
                        icon: Icon(
                          Icons.person_outline,
                          color: scheme.onSurfaceVariant,
                          size: 24,
                        ),
                        selectedIcon: Icon(
                          Icons.person,
                          color: scheme.primary,
                          size: 24,
                        ),
                        label: l10n.mainNavProfile,
                      ),
                      NavigationDestination(
                        icon: Icon(
                          Icons.settings_outlined,
                          color: scheme.onSurfaceVariant,
                          size: 24,
                        ),
                        selectedIcon: Icon(
                          Icons.settings,
                          color: scheme.primary,
                          size: 24,
                        ),
                        label: l10n.settings,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
