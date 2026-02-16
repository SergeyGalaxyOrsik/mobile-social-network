import 'package:equatable/equatable.dart';

import 'package:mobile_social_network/features/auth/domain/entities/user_entity.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Начальное состояние или загрузка проверки авторизации.
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Пользователь не авторизован — показать экран входа.
class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

/// Пользователь авторизован — перейти на главный экран.
class AuthAuthenticated extends AuthState {
  const AuthAuthenticated(this.user);

  final UserEntity user;

  @override
  List<Object?> get props => [user];
}

/// Идёт вход (проверка логина/пароля).
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// Ошибка входа (неверный email/пароль).
class AuthError extends AuthState {
  const AuthError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
