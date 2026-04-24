import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mobile_social_network/core/notifications/push_navigation.dart';
import 'package:mobile_social_network/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:mobile_social_network/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:mobile_social_network/features/auth/presentation/bloc/auth_state.dart';

/// Регистрация FCM-токена на бэкенде, обновление токена и маршрутизация по пушам.
class PushLifecycleHost extends StatefulWidget {
  const PushLifecycleHost({
    super.key,
    required this.authRemote,
    required this.child,
  });

  final AuthRemoteDataSource authRemote;
  final Widget child;

  @override
  State<PushLifecycleHost> createState() => _PushLifecycleHostState();
}

class _PushLifecycleHostState extends State<PushLifecycleHost> {
  StreamSubscription<RemoteMessage>? _foregroundSub;
  StreamSubscription<RemoteMessage>? _openedSub;
  StreamSubscription<String>? _tokenRefreshSub;

  static String _pushPlatform() {
    if (kIsWeb) {
      return 'web';
    }
    return switch (defaultTargetPlatform) {
      TargetPlatform.iOS => 'ios',
      _ => 'android',
    };
  }

  @override
  void initState() {
    super.initState();
    _foregroundSub = FirebaseMessaging.onMessage.listen((message) {
      if (!mounted) {
        return;
      }
      if (context.read<AuthBloc>().state is! AuthAuthenticated) {
        return;
      }
      PushNavigation.showForegroundBanner(message);
    });
    _openedSub = FirebaseMessaging.onMessageOpenedApp.listen((message) {
      if (!mounted) {
        return;
      }
      if (context.read<AuthBloc>().state is! AuthAuthenticated) {
        return;
      }
      PushNavigation.handleNotificationOpened(message);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) {
        return;
      }
      if (context.read<AuthBloc>().state is AuthAuthenticated) {
        await _registerPushToken();
        _listenTokenRefresh();
      }
      final initial = await FirebaseMessaging.instance.getInitialMessage();
      if (!mounted || initial == null) {
        return;
      }
      if (context.read<AuthBloc>().state is AuthAuthenticated) {
        PushNavigation.handleNotificationOpened(initial);
      } else {
        PendingPushOpenMessage.assign(initial);
      }
    });
  }

  @override
  void dispose() {
    _foregroundSub?.cancel();
    _openedSub?.cancel();
    _tokenRefreshSub?.cancel();
    super.dispose();
  }

  Future<void> _registerPushToken() async {
    final token = await FirebaseMessaging.instance.getToken();
    if (token == null || token.isEmpty) {
      return;
    }
    try {
      await widget.authRemote.registerPushToken(
        token,
        platform: _pushPlatform(),
      );
    } catch (_) {}
  }

  void _listenTokenRefresh() {
    _tokenRefreshSub?.cancel();
    _tokenRefreshSub = FirebaseMessaging.instance.onTokenRefresh.listen((
      newToken,
    ) async {
      if (!mounted) {
        return;
      }
      if (context.read<AuthBloc>().state is! AuthAuthenticated) {
        return;
      }
      try {
        await widget.authRemote.registerPushToken(
          newToken,
          platform: _pushPlatform(),
        );
      } catch (_) {}
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (previous, current) =>
          (current is AuthAuthenticated && previous is! AuthAuthenticated) ||
          (current is! AuthAuthenticated && previous is AuthAuthenticated),
      listener: (context, state) async {
        if (state is AuthAuthenticated) {
          await _registerPushToken();
          _listenTokenRefresh();
          final pending = PendingPushOpenMessage.take();
          if (pending != null && context.mounted) {
            PushNavigation.handleNotificationOpened(pending);
          }
        } else {
          await _tokenRefreshSub?.cancel();
          _tokenRefreshSub = null;
        }
      },
      child: widget.child,
    );
  }
}
