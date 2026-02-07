import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'package:shared/shared.dart';
import 'services/admin_theme_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize API Backend
  await ApiService.instance.initApi();

  runApp(const MaliAdminApp());
}

class MaliAdminApp extends StatelessWidget {
  const MaliAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: AdminThemeService.instance.themeMode,
      builder: (context, mode, child) {
        return MaterialApp(
          title: 'Mali Matrimony Admin',
          debugShowCheckedModeBanner: false,
          theme: AppStyles.getThemeData(),
          darkTheme: AppStyles.getDarkThemeData(),
          themeMode: mode,
          home: const AdminLoginScreen(),
        );
      },
    );
  }
}
