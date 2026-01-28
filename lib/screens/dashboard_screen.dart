import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/notification_service.dart';
import 'notifications_screen.dart';
import 'matches_screen.dart';
import 'search_screen.dart';
import 'chat_list_screen.dart';
import 'user_profile_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const _HomeView(),
    const MatchesScreen(),
    const ChatListScreen(),
    const UserProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFD1C8),
      appBar: AppBar(
        title: Text(
          _getAppBarTitle(),
          style: const TextStyle(
            color: Color(0xFF820815),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFFFFD1C8),
        elevation: 0,
        actions: [
          Consumer<NotificationService>(
            builder: (context, notificationService, child) {
              final unreadCount = notificationService.unreadCount;
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.notifications_outlined,
                      color: Color(0xFF820815),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NotificationsScreen(),
                        ),
                      );
                    },
                  ),
                  if (unreadCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Color(0xFF820815),
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          unreadCount > 9 ? '9+' : '$unreadCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          if (_selectedIndex == 3) // Only on Profile Tab
            PopupMenuButton<String>(
              icon: const Icon(
                Icons.more_vert_rounded,
                color: Color(0xFF820815),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              onSelected: (value) {
                // Implement functionality
              },
              itemBuilder: (context) => [
                _buildPopupMenuItem(Icons.settings_outlined, "Settings"),
                _buildPopupMenuItem(Icons.help_outline, "Help & Support"),
                _buildPopupMenuItem(Icons.policy_outlined, "Privacy Policy"),
              ],
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: IndexedStack(index: _selectedIndex, children: _screens),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(100),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF820815).withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            backgroundColor: Colors.white,
            selectedItemColor: const Color(0xFF820815),
            unselectedItemColor: const Color(0xFF820815).withValues(alpha: 0.4),
            type: BottomNavigationBarType.fixed,
            showSelectedLabels: true,
            showUnselectedLabels: false,
            elevation: 0,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_rounded),
                label: "Home",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.favorite_rounded),
                label: "Matches",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.chat_bubble_rounded),
                label: "Chat",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_rounded),
                label: "Profile",
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getAppBarTitle() {
    switch (_selectedIndex) {
      case 1:
        return "New Matches";
      case 2:
        return "Messages";
      case 3:
        return "My Profile";
      default:
        return "Mali Matrimony";
    }
  }

  PopupMenuItem<String> _buildPopupMenuItem(IconData icon, String title) {
    return PopupMenuItem<String>(
      value: title,
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF820815), size: 20),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF820815),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          _buildSearchBar(context),
          const SizedBox(height: 48),
          const Center(
            child: Column(
              children: [
                Icon(Icons.favorite, size: 80, color: Color(0xFF820815)),
                SizedBox(height: 24),
                Text(
                  "Welcome to\nMali Matrimony",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF820815),
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  "Discover matches near you.",
                  style: TextStyle(fontSize: 16, color: Color(0xFF820815)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SearchScreen()),
        );
      },
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(100),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF820815).withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.search, color: Color(0xFF820815)),
            const SizedBox(width: 12),
            Text(
              "Search by name, location, or caste...",
              style: TextStyle(
                color: const Color(0xFF820815).withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
