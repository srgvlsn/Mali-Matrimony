import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared/shared.dart';
import 'screens/splash_screen.dart';
import 'services/notification_service.dart';
import 'services/profile_service.dart';
import 'services/interest_service.dart';
import 'services/chat_service.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NotificationService()),
        ChangeNotifierProvider(create: (_) => ProfileService()),
        ChangeNotifierProvider(create: (_) => InterestService()),
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
