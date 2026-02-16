import 'package:flutter/material.dart';

/// Провайдер текущей [Locale] и колбэка для смены языка.
class LocaleScope extends InheritedWidget {
  const LocaleScope({
    super.key,
    required this.locale,
    required this.setLocale,
    required super.child,
  });

  final Locale? locale;
  final ValueChanged<Locale?> setLocale;

  static LocaleScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<LocaleScope>();
    assert(scope != null, 'LocaleScope not found');
    return scope!;
  }

  @override
  bool updateShouldNotify(LocaleScope oldWidget) =>
      locale != oldWidget.locale;
}
