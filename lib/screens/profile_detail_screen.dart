import 'package:flutter/material.dart';

class ProfileDetailScreen extends StatelessWidget {
  final String userId;

  const ProfileDetailScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFD1C8),
      appBar: AppBar(
        title: const Text(
          'Profile Details',
          style: TextStyle(
            color: Color(0xFF820815),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFFFFD1C8),
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF820815)),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 60,
              backgroundColor: Color(0xFF820815),
              child: Icon(Icons.person, size: 60, color: Colors.white),
            ),
            const SizedBox(height: 24),
            Text(
              'User ID: $userId',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF820815),
              ),
            ),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'This is a placeholder for the profile detail screen. In a real app, you would fetch and display the full profile of the user here.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF820815)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
