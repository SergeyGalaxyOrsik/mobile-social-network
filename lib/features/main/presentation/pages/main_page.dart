import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mobile_social_network/features/auth/domain/entities/user_entity.dart';
import 'package:mobile_social_network/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:mobile_social_network/features/auth/presentation/bloc/auth_event.dart';
import 'package:mobile_social_network/features/main/presentation/pages/settings_page.dart';
import 'package:mobile_social_network/l10n/app_localizations.dart';

/// Главный экран приложения после успешной авторизации.
class MainPage extends StatelessWidget {
  const MainPage({super.key, required this.user});

  final UserEntity user;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.home),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (context) => const SettingsPage(),
                ),
              );
            },
            tooltip: l10n.settings,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthBloc>().add(const AuthSignOutRequested());
            },
            tooltip: l10n.logout,
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              l10n.helloUser(user.displayName ?? user.email),
              style: Theme.of(context).textTheme.displayLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              user.email,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
