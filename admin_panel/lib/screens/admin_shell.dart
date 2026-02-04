import 'package:flutter/material.dart';
import '../widgets/admin_sidebar.dart';
import 'dashboard_screen.dart';
import 'verification_screen.dart';
import 'user_list_screen.dart';
import 'settings_screen.dart';
import 'package:shared/shared.dart';

import '../services/admin_socket_service.dart';

class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    AdminSocketService.instance.connect();
  }

  @override
  void dispose() {
    AdminSocketService.instance.disconnect();
    super.dispose();
  }

  final List<Widget> _screens = [
    const AdminDashboardScreen(),
    const VerificationScreen(),
    const UserListScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isLargeScreen = constraints.maxWidth >= 1100;

        return Scaffold(
          drawer: isLargeScreen
              ? null
              : Drawer(
                  child: AdminSidebar(
                    selectedIndex: _selectedIndex,
                    onItemSelected: (index) {
                      setState(() {
                        _selectedIndex = index;
                      });
                      Navigator.pop(context); // Close drawer
                    },
                  ),
                ),
          appBar: isLargeScreen
              ? null
              : AppBar(
                  title: const Text(
                    "Admin Portal",
                    style: TextStyle(
                      color: AppStyles.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  backgroundColor: Colors.white,
                  elevation: 1,
                  leading: Builder(
                    builder: (context) => IconButton(
                      icon: const Icon(Icons.menu, color: AppStyles.primary),
                      onPressed: () => Scaffold.of(context).openDrawer(),
                    ),
                  ),
                ),
          body: Row(
            children: [
              // Sidebar (fixed on large screens)
              if (isLargeScreen)
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
      },
    );
  }
}
