import 'package:flutter/material.dart';
import '../widgets/admin_sidebar.dart';
import 'dashboard_screen.dart';
import 'verification_screen.dart';
import 'user_list_screen.dart';
import 'settings_screen.dart';

class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const AdminDashboardScreen(),
    const VerificationScreen(),
    const UserListScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          AdminSidebar(
            selectedIndex: _selectedIndex,
            onItemSelected: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
          ),
          // Content
          Expanded(child: _screens[_selectedIndex]),
        ],
      ),
    );
  }
}
