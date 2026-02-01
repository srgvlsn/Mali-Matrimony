import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'services/admin_mock_service.dart';
import 'package:shared/shared.dart';

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
      theme: AppStyles.getThemeData().copyWith(
        // Admin specific overrides
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const AdminLoginScreen(),
    );
  }
}
