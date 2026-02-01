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
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        primary: primary,
        onPrimary: background,
        surface: background,
        onSurface: primary,
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: primary),
        bodyMedium: TextStyle(color: primary),
        bodySmall: TextStyle(color: primary),
        titleLarge: TextStyle(color: primary, fontWeight: FontWeight.bold),
      ),
      inputDecorationTheme: InputDecorationTheme(
        labelStyle: const TextStyle(color: primary),
        hintStyle: const TextStyle(color: primary),
        floatingLabelStyle: const TextStyle(color: primary),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: primary),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: primary, width: 2),
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
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: primary,
        selectionColor: Color(0x33820815),
        selectionHandleColor: primary,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: background,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
