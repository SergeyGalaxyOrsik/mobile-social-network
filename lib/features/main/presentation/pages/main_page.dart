import 'package:flutter/material.dart';

import 'package:mobile_social_network/features/auth/domain/entities/user_entity.dart';
import 'package:mobile_social_network/features/feed/presentation/pages/feed_page.dart';
import 'package:mobile_social_network/features/main/presentation/pages/settings_page.dart';
import 'package:mobile_social_network/l10n/app_localizations.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key, required this.user});

  final UserEntity user;

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  static Color _navBarSurfaceColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Theme.of(context).colorScheme.surface
        : Colors.transparent;
  }

  Widget _buildPage(int index) {
    switch (index) {
      case 0:
        return _buildHomeContent();
      case 1:
        return const SettingsPage();
      default:
        return _buildHomeContent();
    }
  }

  Widget _buildHomeContent() {
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
                  child: Text(
                    l10n.helloUser(
                      widget.user.displayName ?? widget.user.email,
                    ),
                    style: Theme.of(context).textTheme.displayMedium,
                    textAlign: TextAlign.left,
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
    return Scaffold(
      body: _buildPage(_selectedIndex),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
              onPressed: () => _openCreatePost(context),
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
            data: Theme.of(context).copyWith(
              colorScheme: Theme.of(
                context,
              ).colorScheme.copyWith(surface: _navBarSurfaceColor(context)),
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              splashFactory: NoSplash.splashFactory,
              navigationBarTheme: NavigationBarThemeData(
                height: 20,
                surfaceTintColor: Colors.transparent,
                indicatorColor: Colors.transparent,
              ),
            ),
            child: NavigationBar(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (index) =>
                  setState(() => _selectedIndex = index),
              backgroundColor: _navBarSurfaceColor(context),
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
              destinations: [
                NavigationDestination(
                  icon: Icon(
                    Icons.home_outlined,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    size: 26,
                  ),
                  selectedIcon: Icon(
                    Icons.home,
                    color: Theme.of(context).colorScheme.primary,
                    size: 26,
                  ),
                  label: '',
                ),
                NavigationDestination(
                  icon: Icon(
                    Icons.settings_outlined,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    size: 26,
                  ),
                  selectedIcon: Icon(
                    Icons.settings,
                    color: Theme.of(context).colorScheme.primary,
                    size: 26,
                  ),
                  label: '',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
