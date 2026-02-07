import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminThemeService {
  static final AdminThemeService instance = AdminThemeService._internal();
  AdminThemeService._internal() {
    _loadTheme();
  }

  static const String _themeKey = 'admin_theme_mode';

  final ValueNotifier<ThemeMode> themeMode = ValueNotifier<ThemeMode>(
    ThemeMode.light,
  );

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final String? themeStr = prefs.getString(_themeKey);
    if (themeStr != null) {
      if (themeStr == 'dark') {
        themeMode.value = ThemeMode.dark;
      } else if (themeStr == 'light') {
        themeMode.value = ThemeMode.light;
      } else {
        themeMode.value = ThemeMode.system;
      }
    }
  }

  Future<void> toggleTheme() async {
    if (themeMode.value == ThemeMode.light) {
      themeMode.value = ThemeMode.dark;
      await _saveTheme('dark');
    } else {
      themeMode.value = ThemeMode.light;
      await _saveTheme('light');
    }
  }

  Future<void> _saveTheme(String mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, mode);
  }

  bool get isDarkMode => themeMode.value == ThemeMode.dark;
}
