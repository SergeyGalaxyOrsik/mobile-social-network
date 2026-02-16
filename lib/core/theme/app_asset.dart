import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Централизованные ресурсы приложения: шрифты, заготовки стилей и цвета.
abstract final class AppAsset {
  AppAsset._();

  // ─────────────────────────────────────────────────────────────────────────
  // Шрифты (Google Fonts)
  // ─────────────────────────────────────────────────────────────────────────

  /// Шрифт для заголовков (display, headline, title).
  static TextStyle get headingFont => GoogleFonts.handjet();

  /// Шрифт для основного текста (body, label).
  static TextStyle get bodyFont => GoogleFonts.roboto();

  /// Тема текста: Handjet для заголовков, Roboto для остального.
  static TextTheme get textTheme {
    final handjet = GoogleFonts.handjetTextTheme();
    final roboto = GoogleFonts.robotoTextTheme();
    return TextTheme(
      // Заголовки — Handjet
      displayLarge: handjet.displayLarge,
      displayMedium: handjet.displayMedium,
      displaySmall: handjet.displaySmall,
      headlineLarge: handjet.headlineLarge,
      headlineMedium: handjet.headlineMedium,
      headlineSmall: handjet.headlineSmall,
      titleLarge: handjet.titleLarge,
      titleMedium: handjet.titleMedium,
      titleSmall: handjet.titleSmall,
      // Основной текст — Roboto
      bodyLarge: roboto.bodyLarge,
      bodyMedium: roboto.bodyMedium,
      bodySmall: roboto.bodySmall,
      labelLarge: roboto.labelLarge,
      labelMedium: roboto.labelMedium,
      labelSmall: roboto.labelSmall,
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Заготовки стилей текста
  // ─────────────────────────────────────────────────────────────────────────

  /// Крупный заголовок (display).
  static TextStyle get displayStyle => GoogleFonts.handjet();

  /// Заголовок (headline).
  static TextStyle get headlineStyle => GoogleFonts.handjet();

  /// Подзаголовок (title).
  static TextStyle get titleStyle => GoogleFonts.handjet();

  /// Основной текст.
  static TextStyle get bodyStyle => GoogleFonts.roboto();

  /// Подпись / метка.
  static TextStyle get labelStyle => GoogleFonts.roboto();

  /// Заголовок с размером и опциональным цветом.
  static TextStyle heading({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
  }) =>
      GoogleFonts.handjet(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
      );

  /// Основной текст с размером и опциональным цветом.
  static TextStyle body({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
  }) =>
      GoogleFonts.roboto(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
      );

  // ─────────────────────────────────────────────────────────────────────────
  // Цвета (по макетам)
  // ─────────────────────────────────────────────────────────────────────────

  /// Акцент — оранжевый (светлая и тёмная тема).
  static const Color accent = Color(0xFFFA4300);

  // --- Светлая тема ---

  /// Фон приложения (между карточками).
  static const Color backgroundLight = Color(0xFFEDF1F2);

  /// Фон карточек контента (посты, блоки).
  static const Color cardBackgroundLight = Color(0xFFFFFFFF);

  /// Заголовки, время в статус-баре — чистый чёрный.
  static const Color headlineLight = Color(0xFF000000);

  /// Основной и вторичный текст на карточках.
  static const Color textLight = Color(0xFF030303);

  /// Второстепенный текст (описания, счётчики) — тёмно-серый.
  static const Color textSecondaryLight = Color(0xFF4A4A4A);

  /// Обводка outline-кнопки, границы.
  static const Color outlineLight = Color(0xFF030303);

  /// Иконки (outline, неактивные).
  static const Color iconLight = Color(0xFF707070);

  /// Иконка активная (например, home в bottom nav).
  static const Color iconActiveLight = Color(0xFF000000);

  /// Разделители между постами, линия под навбаром.
  static const Color dividerLight = Color(0xFFE0E0E0);

  // --- Тёмная тема ---

  /// Фон приложения.
  static const Color backgroundDark = Color(0xFF030303);

  /// Fill-кнопка (заливка белая, текст тёмный).
  static const Color fillButtonDark = Color(0xFFFFFFFF);

  /// Outline-кнопка: граница и текст белые, фон #030303.
  static const Color outlineDark = Color(0xFFFFFFFF);

  /// Основной текст и иконки на тёмном фоне.
  static const Color textOnDark = Color(0xFFFFFFFF);

  /// Текст на белой кнопке (Edit profile).
  static const Color textOnFillButton = Color(0xFF030303);

  /// Второстепенный текст (время, счётчики).
  static const Color textSecondaryDark = Color(0xFFB0B0B0);

  /// Карточки/аватарки — тёмно-серый.
  static const Color cardBackgroundDark = Color(0xFF1A1A1A);

  // Системные (error и т.д.)
  static const Color error = Color(0xFFB3261E);
  static const Color errorContainer = Color(0xFFF9DEDC);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color onErrorContainer = Color(0xFF410E0B);

  // ─────────────────────────────────────────────────────────────────────────
  // Светлая тема
  // ─────────────────────────────────────────────────────────────────────────

  /// Схема цветов светлой темы (по макету).
  static ColorScheme get colorSchemeLight => ColorScheme.light(
        primary: accent,
        onPrimary: textOnDark,
        primaryContainer: accent,
        onPrimaryContainer: textOnDark,
        secondary: textLight,
        onSecondary: cardBackgroundLight,
        secondaryContainer: cardBackgroundLight,
        onSecondaryContainer: textLight,
        surface: backgroundLight,
        onSurface: headlineLight,
        surfaceContainerLowest: cardBackgroundLight,
        surfaceContainerHighest: backgroundLight,
        onSurfaceVariant: textSecondaryLight,
        outline: outlineLight,
        outlineVariant: dividerLight,
        error: error,
        onError: onError,
        errorContainer: errorContainer,
        onErrorContainer: onErrorContainer,
      );

  /// Светлая тема приложения.
  static ThemeData get themeLight => ThemeData(
        colorScheme: colorSchemeLight,
        textTheme: textTheme.apply(
          bodyColor: colorSchemeLight.onSurface,
          displayColor: colorSchemeLight.onSurface,
        ),
        useMaterial3: true,
      ).copyWith(
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: accent,
            foregroundColor: textOnDark,
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: textLight,
            side: const BorderSide(color: outlineLight),
          ),
        ),
        dividerColor: dividerLight,
        iconTheme: const IconThemeData(color: iconLight, size: 24),
      );

  // ─────────────────────────────────────────────────────────────────────────
  // Тёмная тема
  // ─────────────────────────────────────────────────────────────────────────

  /// Схема цветов тёмной темы (по макету).
  static ColorScheme get colorSchemeDark => ColorScheme.dark(
        primary: accent,
        onPrimary: textOnDark,
        primaryContainer: accent,
        onPrimaryContainer: textOnDark,
        secondary: fillButtonDark,
        onSecondary: textOnFillButton,
        secondaryContainer: cardBackgroundDark,
        onSecondaryContainer: textOnDark,
        surface: backgroundDark,
        onSurface: textOnDark,
        surfaceContainerLowest: cardBackgroundDark,
        surfaceContainerHighest: backgroundDark,
        onSurfaceVariant: textSecondaryDark,
        outline: outlineDark,
        outlineVariant: outlineDark,
        error: error,
        onError: onError,
        errorContainer: errorContainer,
        onErrorContainer: onErrorContainer,
      );

  /// Тёмная тема приложения.
  static ThemeData get themeDark => ThemeData(
        colorScheme: colorSchemeDark,
        textTheme: textTheme.apply(
          bodyColor: colorSchemeDark.onSurface,
          displayColor: colorSchemeDark.onSurface,
        ),
        useMaterial3: true,
        brightness: Brightness.dark,
      ).copyWith(
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: fillButtonDark,
            foregroundColor: textOnFillButton,
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: textOnDark,
            side: const BorderSide(color: outlineDark),
          ),
        ),
        dividerColor: cardBackgroundDark,
        iconTheme: const IconThemeData(color: textOnDark, size: 24),
      );

  // ─────────────────────────────────────────────────────────────────────────
  // Совместимость (дефолт = светлая)
  // ─────────────────────────────────────────────────────────────────────────

  /// Схема цветов (светлая). Для тёмной используйте [colorSchemeDark].
  static ColorScheme get colorScheme => colorSchemeLight;

  /// Базовая тема приложения (светлая). Для тёмной используйте [themeDark].
  static ThemeData get theme => themeLight;
}
