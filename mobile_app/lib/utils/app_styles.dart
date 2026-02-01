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
}
