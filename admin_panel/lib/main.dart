import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'package:shared/shared.dart';

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
