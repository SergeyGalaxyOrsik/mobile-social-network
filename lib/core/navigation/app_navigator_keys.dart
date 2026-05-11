import 'package:flutter/material.dart';

/// Корневой [Navigator] [MaterialApp] — локализации и общий контекст.
final GlobalKey<NavigatorState> appRootNavigatorKey =
    GlobalKey<NavigatorState>();

/// [ScaffoldMessenger] для in-app уведомлений о пуше (поверх вложенных экранов).
final GlobalKey<ScaffoldMessengerState> appRootMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

/// [Navigator] с [MainPage] (внутренний стек после входа).
final GlobalKey<NavigatorState> appShellNavigatorKey =
    GlobalKey<NavigatorState>();
