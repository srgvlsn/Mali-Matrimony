import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared/shared.dart';
import 'screens/splash_screen.dart';
import 'services/notification_service.dart';
import 'services/profile_service.dart';
import 'services/interest_service.dart';
import 'services/chat_service.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final profileService = ProfileService();
  final interestService = InterestService();

  // ignore: unawaited_futures
  profileService.fetchProfiles();
  // ignore: unawaited_futures
  interestService.fetchInterests();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NotificationService()),
        ChangeNotifierProvider.value(value: profileService),
        ChangeNotifierProvider.value(value: interestService),
        ChangeNotifierProvider.value(value: AuthService.instance),
        ChangeNotifierProvider(create: (_) => ChatService()),
      ],
      child: const MaliMatrimonyApp(),
    ),
  );
}

class MaliMatrimonyApp extends StatelessWidget {
  const MaliMatrimonyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mali Matrimony',
      theme: AppStyles.getThemeData(),
      home: const SplashScreen(),
    );
  }
}
