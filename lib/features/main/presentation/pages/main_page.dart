import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mobile_social_network/features/auth/domain/entities/user_entity.dart';
import 'package:mobile_social_network/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:mobile_social_network/features/auth/presentation/bloc/auth_event.dart';
import 'package:mobile_social_network/features/main/presentation/pages/settings_page.dart';

/// Главный экран приложения после успешной авторизации.
class MainPage extends StatelessWidget {
  const MainPage({super.key, required this.user});

  final UserEntity user;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Главная'),
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
            tooltip: 'Настройки',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthBloc>().add(const AuthSignOutRequested());
            },
            tooltip: 'Выйти',
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Привет, ${user.displayName ?? user.email}!',
              style: Theme.of(context).textTheme.titleLarge,
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
