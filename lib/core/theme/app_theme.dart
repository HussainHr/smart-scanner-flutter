import 'package:flutter/material.dart';

abstract final class AppTheme {
  static const Color scaffoldDark = Color(0xFF12171E);
  static const Color appBarDark = Color(0xFF0F1419);
  static const Color surfaceDark = Color(0xFF1A1F26);
  static const Color accentTeal = Color(0xFF66CDAA);
  static const Color onAccent = Color(0xFF12171E);
  static const Color onSurfaceDark = Color(0xFFE8EAED);
  static const Color outlineDark = Color(0xFF2A313C);
  static const Color errorRed = Color(0xFFDC2626);
  static const Color previewRowAlt = Color(0xFF232A33);
  static const Color fileListBackground = Color(0xFF121212);
  static const Color fileListAppBar = Color(0xFF005B6F);
  static const Color fileListCard = Color(0xFF2C2C2E);
  static const Color fileListDelete = Color(0xFFB00020);
  static const Color fileListSubtitle = Color(0xFFB0B0B0);

  /// Scanner screen palette (reference UI).
  static const Color scannerBackground = Color(0xFF121B22);
  static const Color scannerAppBar = Color(0xFF0F161C);
  static const Color scannerMint = Color(0xFF66D2B3);
  static const Color scannerMintOn = Color(0xFF121B22);
  static const Color scannerTeal = Color(0xFF004D40);
  static const Color scannerInputBg = Color(0xFF1A2330);
  static const Color scannerInputBorder = Color(0xFF3A4555);

  static ThemeData get dark {
    final colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: accentTeal,
      onPrimary: onAccent,
      secondary: accentTeal,
      onSecondary: onAccent,
      surface: surfaceDark,
      onSurface: onSurfaceDark,
      error: errorRed,
      onError: Colors.white,
      outline: outlineDark,
      outlineVariant: outlineDark,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: scaffoldDark,
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: appBarDark,
        foregroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.white),
        actionsIconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: surfaceDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: outlineDark),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: accentTeal,
          foregroundColor: onAccent,
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: accentTeal,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: surfaceDark,
        contentTextStyle: const TextStyle(color: onSurfaceDark),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      dividerColor: outlineDark,
    );
  }
}
