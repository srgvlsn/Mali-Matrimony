import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/splash_screen.dart';
import 'services/notification_service.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => NotificationService(),
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

      // Global Theme
      theme: ThemeData(
        useMaterial3: true, // optional, makes buttons modern
        // Background color for all screens
        scaffoldBackgroundColor: const Color(0xFFFFD1C8),

        // Primary colors for buttons, accents, etc.
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF820815),
          primary: const Color(0xFF820815),
          onPrimary: const Color(0xFFFFD1C8),
          surface: const Color(0xFFFFD1C8),
          onSurface: const Color(0xFF820815),
        ),

        // Global text theme
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Color(0xFF820815)),
          bodyMedium: TextStyle(color: Color(0xFF820815)),
          bodySmall: TextStyle(color: Color(0xFF820815)),
          titleLarge: TextStyle(
            color: Color(0xFF820815),
            fontWeight: FontWeight.bold,
          ),
        ),

        // Global TextField styling
        inputDecorationTheme: InputDecorationTheme(
          labelStyle: const TextStyle(color: Color(0xFF820815)),
          hintStyle: const TextStyle(color: Color(0xFF820815)),
          floatingLabelStyle: const TextStyle(color: Color(0xFF820815)),

          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(100),
            borderSide: const BorderSide(color: Color(0xFF820815)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(100),
            borderSide: const BorderSide(color: Color(0xFF820815), width: 2),
          ),
        ),

        // Cursor & selection color in TextFields
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: Color(0xFF820815),
          selectionColor: Color(0x33820815), // slightly transparent
          selectionHandleColor: Color(0xFF820815),
        ),

        // Global ElevatedButton styling
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF820815),
            foregroundColor: const Color(0xFFFFD1C8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(100),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),

      home: const SplashScreen(),
    );
  }
}
