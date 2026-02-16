import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Проверить, авторизован ли пользователь (при старте приложения).
class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

/// Вход по email и паролю.
class AuthSignInRequested extends AuthEvent {
  const AuthSignInRequested({required this.email, required this.password});

  final String email;
  final String password;

  @override
  List<Object?> get props => [email, password];
}

/// Регистрация: email, пароль, опционально имя.
class AuthSignUpRequested extends AuthEvent {
  const AuthSignUpRequested({
    required this.email,
    required this.password,
    this.displayName,
  });

  final String email;
  final String password;
  final String? displayName;

  @override
  List<Object?> get props => [email, password, displayName];
}

/// Выход из аккаунта.
class AuthSignOutRequested extends AuthEvent {
  const AuthSignOutRequested();
}
