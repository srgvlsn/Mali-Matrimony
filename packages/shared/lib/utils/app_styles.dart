import 'package:flutter/material.dart';

class AppStyles {
  // Colors (Use Theme.of(context).colorScheme.primary where possible, but these can be helpers)
  static const Color primary = Color(0xFF820815);
  static const Color background = Color(0xFFFFD1C8);
  static const Color surface = Colors.white;

  // Shadows
  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: primary.withValues(
        alpha: 0.1,
      ), // Using withValues as withOpacity is deprecated in user's context possibly, or sticking to what code had
      blurRadius: 15,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> weakShadow = [
    BoxShadow(
      color: primary.withValues(alpha: 0.05),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ];

  static const double radiusS = 16.0;
  static const double radiusM = 20.0;
  static const double radiusL = 30.0;
  static const double radiusFull = 50.0;

  // Reuseable Styles
  static ButtonStyle primaryButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: primary,
    foregroundColor: background,
    padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 14),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
  );

  static ButtonStyle outlinedButtonStyle = OutlinedButton.styleFrom(
    side: const BorderSide(color: primary),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
    foregroundColor: primary,
  );

  static ThemeData getThemeData() {
    return _buildTheme(Brightness.light);
  }

  static ThemeData getDarkThemeData() {
    return _buildTheme(Brightness.dark);
  }

  static ThemeData _buildTheme(Brightness brightness) {
    final bool isDark = brightness == Brightness.dark;
    final Color bgColor = isDark ? const Color(0xFF0F0F0F) : background;
    final Color surfaceColor = isDark ? const Color(0xFF1A1A1A) : surface;
    final Color textColor = isDark ? Colors.white : primary;
    final Color primaryColor = isDark ? const Color(0xFFD64D5D) : primary;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: bgColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: brightness,
        primary: primaryColor,
        onPrimary: isDark ? Colors.white : background,
        surface: surfaceColor,
        onSurface: textColor,
      ),
      textTheme: TextTheme(
        bodyLarge: TextStyle(color: textColor),
        bodyMedium: TextStyle(color: textColor),
        bodySmall: TextStyle(color: textColor),
        titleLarge: TextStyle(color: textColor, fontWeight: FontWeight.bold),
      ),
      inputDecorationTheme: InputDecorationTheme(
        labelStyle: TextStyle(color: textColor),
        hintStyle: TextStyle(color: textColor.withValues(alpha: 0.6)),
        floatingLabelStyle: TextStyle(color: primaryColor),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(
            color: isDark ? textColor.withValues(alpha: 0.3) : primaryColor,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: primaryColor,
        selectionColor: primaryColor.withValues(alpha: 0.3),
        selectionHandleColor: primaryColor,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: isDark ? Colors.white : background,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
      cardTheme: CardThemeData(
        color: surfaceColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusL),
        ),
      ),
    );
  }
}
