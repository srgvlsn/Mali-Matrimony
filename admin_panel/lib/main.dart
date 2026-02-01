import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'services/admin_mock_service.dart';
import 'utils/app_styles.dart';

void main() {
  // Initialize Mock Service
  AdminMockService.instance.init();

  runApp(const MaliAdminApp());
}

class MaliAdminApp extends StatelessWidget {
  const MaliAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mali Matrimony Admin',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppStyles.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppStyles.primary,
          primary: AppStyles.primary,
          onPrimary: AppStyles.background,
          surface: AppStyles.background,
          onSurface: AppStyles.primary,
        ),
        fontFamily: 'Roboto',
      ),
      home: const AdminLoginScreen(),
    );
  }
}
