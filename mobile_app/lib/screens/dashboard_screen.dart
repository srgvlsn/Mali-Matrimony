import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../services/notification_service.dart';
import '../services/auth_service.dart';
import '../services/chat_service.dart';
import '../services/interest_service.dart';
import 'profile_detail_screen.dart';
import 'chat_list_screen.dart';
import 'user_profile_screen.dart';
import 'interests_screen.dart';
import '../services/profile_service.dart';
import 'package:shared/shared.dart';
import '../widgets/user_card.dart';
import '../widgets/custom_search_bar.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatService>().fetchConversations();
    });
  }

  final List<Widget> _screens = [
    const _HomeView(),
    const InterestsScreen(),
    const ChatListScreen(),
    const UserProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: _selectedIndex == 1
          ? null
          : AppBar(
              title: Text(
                _getAppBarTitle(),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              surfaceTintColor: Colors.transparent,
              scrolledUnderElevation: 0,
              elevation: 0,
              systemOverlayStyle: const SystemUiOverlayStyle(
                statusBarColor: Colors.transparent,
                statusBarIconBrightness: Brightness.dark,
                systemNavigationBarColor: Colors.transparent,
                systemNavigationBarIconBrightness: Brightness.dark,
              ),
              actions: [
                Consumer<NotificationService>(
                  builder: (context, notificationService, child) {
                    final unreadCount = notificationService.unreadCount;
                    return Stack(
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.notifications_outlined,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          onPressed: () {
                            _showNotificationPopup(context);
                          },
                        ),
                        if (notificationService.showIndicator)
                          Positioned(
                            right: 8,
                            top: 8,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
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
                    icon: Icon(
                      Icons.more_vert_rounded,
                      color: Theme.of(context).colorScheme.primary,
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
                      _buildPopupMenuItem(
                        Icons.policy_outlined,
                        "Privacy Policy",
                      ),
                    ],
                  ),
                const SizedBox(width: 8),
              ],
            ),
      body: IndexedStack(index: _selectedIndex, children: _screens),
      bottomNavigationBar: SafeArea(
        child: Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(100),
            boxShadow: AppStyles.cardShadow,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: MediaQuery.removePadding(
              context: context,
              removeBottom: true,
              child: Consumer2<InterestService, ChatService>(
                builder: (context, interestService, chatService, child) {
                  return BottomNavigationBar(
                    currentIndex: _selectedIndex,
                    onTap: (index) {
                      setState(() {
                        _selectedIndex = index;
                      });
                    },
                    backgroundColor: Colors.white,
                    selectedItemColor: Theme.of(context).colorScheme.primary,
                    unselectedItemColor: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.4),
                    type: BottomNavigationBarType.fixed,
                    showSelectedLabels: true,
                    showUnselectedLabels: false,
                    elevation: 0,
                    items: [
                      const BottomNavigationBarItem(
                        icon: Icon(Icons.home_rounded),
                        label: "Home",
                      ),
                      BottomNavigationBarItem(
                        icon: Badge(
                          label: Text('${interestService.unreadReceivedCount}'),
                          isLabelVisible:
                              interestService.unreadReceivedCount > 0,
                          child: const Icon(Icons.star_rounded),
                        ),
                        label: "Interests",
                      ),
                      BottomNavigationBarItem(
                        icon: Badge(
                          label: Text('${chatService.totalUnreadCount}'),
                          isLabelVisible: chatService.totalUnreadCount > 0,
                          child: const Icon(Icons.chat_bubble_rounded),
                        ),
                        label: "Chat",
                      ),
                      const BottomNavigationBarItem(
                        icon: Icon(Icons.person_rounded),
                        label: "Profile",
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getAppBarTitle() {
    switch (_selectedIndex) {
      case 1:
        return "Interests Hub";
      case 2:
        return "Messages";
      case 3:
        return "My Profile";
      default:
        return "Mali Matrimony";
    }
  }

  void _showNotificationPopup(BuildContext context) {
    final notificationService = Provider.of<NotificationService>(
      context,
      listen: false,
    );
    notificationService.fetchForCurrentUser();
    notificationService.clearIndicator();
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Notifications",
      barrierColor: Colors.black.withValues(alpha: 0.2),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) => Container(),
      transitionBuilder: (context, anim1, anim2, child) {
        return Transform.scale(
          scale: anim1.value,
          child: Opacity(
            opacity: anim1.value,
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  20,
                  MediaQuery.of(context).padding.top + kToolbarHeight + 2,
                  20,
                  100,
                ),
                child: Material(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(32),
                  elevation: 8,
                  child: Consumer<NotificationService>(
                    builder: (context, notificationService, child) {
                      final notifications = notificationService.notifications;
                      return Container(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(
                                24,
                                24,
                                24,
                                12,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Notifications",
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: Icon(
                                          Icons.refresh_rounded,
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.primary,
                                        ),
                                        onPressed: () => notificationService
                                            .fetchForCurrentUser(),
                                      ),
                                      if (notificationService.unreadCount > 0)
                                        TextButton(
                                          onPressed: () => notificationService
                                              .markAllAsRead(),
                                          child: Text(
                                            "Mark all as read",
                                            style: TextStyle(
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.primary,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Flexible(
                              child: notifications.isEmpty
                                  ? Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 32,
                                      ),
                                      child: _buildEmptyNotifications(),
                                    )
                                  : ListView.builder(
                                      shrinkWrap: true,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                      ),
                                      itemCount: notifications.length,
                                      itemBuilder: (context, index) {
                                        final notification =
                                            notifications[index];
                                        return _buildNotificationCard(
                                          context,
                                          notification,
                                          notificationService,
                                        );
                                      },
                                    ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyNotifications() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none_rounded,
            size: 64,
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            "No notifications yet",
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(
    BuildContext context,
    NotificationModel notification,
    NotificationService service,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 0,
      color: notification.isRead
          ? Colors.white.withValues(alpha: 0.6)
          : Colors.white,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            service.getIconForType(notification.type),
            color: Theme.of(context).colorScheme.primary,
            size: 20,
          ),
        ),
        title: Text(
          notification.title,
          style: TextStyle(
            fontWeight: notification.isRead ? FontWeight.w500 : FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              notification.message,
              style: TextStyle(
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _getTimeAgo(notification.timestamp),
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.4),
              ),
            ),
          ],
        ),
        onTap: () {
          final wasUnread = !notification.isRead;
          if (wasUnread) {
            service.markAsRead(notification.id);
          }
          if (notification.title == "Profile Verified") {
            Navigator.pop(context); // Close notification popup
            setState(() => _selectedIndex = 3); // Switch to Profile Tab
            if (wasUnread) {
              // Refresh profile and then trigger animation after a small delay
              // Use unawaited/non-blocking if possible or just wait
              final authService = Provider.of<AuthService>(
                context,
                listen: false,
              );
              final profileService = Provider.of<ProfileService>(
                context,
                listen: false,
              );

              authService.refreshProfile().then((_) {
                Future.delayed(const Duration(milliseconds: 300), () {
                  profileService.triggerBadgeHighlight();
                });
              });
            }
          } else if (notification.relatedUserId != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    ProfileDetailScreen(userId: notification.relatedUserId!),
              ),
            );
          }
        },
      ),
    );
  }

  String _getTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    if (difference.inDays > 0) return DateFormatter.formatShortDate(timestamp);
    if (difference.inHours > 0) return "${difference.inHours}h ago";
    if (difference.inMinutes > 0) return "${difference.inMinutes}m ago";
    return "Just now";
  }

  PopupMenuItem<String> _buildPopupMenuItem(IconData icon, String title) {
    return PopupMenuItem<String>(
      value: title,
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary, size: 20),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeView extends StatefulWidget {
  const _HomeView();

  @override
  State<_HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<_HomeView> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          _buildInternalTabBar(),
          Expanded(
            child: TabBarView(
              children: [
                _buildDiscoveryTab(),
                _buildProfilesTab(isShortlisted: false),
                _buildProfilesTab(isShortlisted: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInternalTabBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 8, 24, 16),
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(100),
        boxShadow: AppStyles.cardShadow,
      ),
      child: TabBar(
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          color: Theme.of(context).colorScheme.primary,
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Theme.of(context).colorScheme.primary,
        labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        tabs: const [
          Tab(text: "Discover"),
          Tab(text: "Suggestions"),
          Tab(text: "Shortlisted"),
        ],
      ),
    );
  }

  Widget _buildDiscoveryTab() {
    return Consumer<ProfileService>(
      builder: (context, profileService, child) {
        if (profileService.isLoading && profileService.profiles.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        final profiles = profileService.profiles;

        return RefreshIndicator(
          onRefresh: () => profileService.fetchProfiles(),
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: CustomSearchBar(),
                ),
                const SizedBox(height: 16),

                // Featured Matches Section
                _buildSectionHeader(context, "Featured Matches", () {
                  DefaultTabController.of(context).animateTo(1);
                }),
                const SizedBox(height: 16),
                SizedBox(
                  height: 280,
                  child: profiles.isEmpty
                      ? const Center(child: Text("No featured matches"))
                      : ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: profiles.length,
                          itemBuilder: (context, index) {
                            return UserCard(
                              profile: profiles[index],
                              isFeatured: true,
                            );
                          },
                        ),
                ),

                const SizedBox(height: 32),

                // Recent Members Section
                _buildSectionHeader(context, "Recent Members", () {
                  DefaultTabController.of(context).animateTo(1);
                }),
                const SizedBox(height: 16),
                profiles.isEmpty
                    ? const Center(child: Text("No recent members"))
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        itemCount: profiles.length > 3 ? 3 : profiles.length,
                        itemBuilder: (context, index) {
                          return UserCard(profile: profiles[index]);
                        },
                      ),
                const SizedBox(height: 32),

                // Profile Reach Dashboard
                _buildProfileReachDashboard(profileService),
                const SizedBox(height: 120),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileReachDashboard(ProfileService profileService) {
    final analytics = profileService.analytics;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Profile Reach",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "Your performance this week",
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.trending_up_rounded,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                _buildReachItem(
                  "Views",
                  analytics?.totalViews.toString() ?? "0",
                  Icons.remove_red_eye_outlined,
                ),
                _buildReachDivider(),
                _buildReachItem(
                  "Interests",
                  analytics?.interestsReceived.toString() ?? "0",
                  Icons.star_outline_rounded,
                ),
                _buildReachDivider(),
                _buildReachItem(
                  "Shortlists",
                  analytics?.shortlistedBy.toString() ?? "0",
                  Icons.favorite_border_rounded,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReachItem(String label, String value, IconData icon) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: Colors.white70, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: const TextStyle(color: Colors.white60, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildReachDivider() {
    return Container(
      height: 40,
      width: 1,
      color: Colors.white.withValues(alpha: 0.2),
    );
  }

  Widget _buildProfilesTab({required bool isShortlisted}) {
    return Consumer<ProfileService>(
      builder: (context, profileService, child) {
        final profiles = isShortlisted
            ? profileService.shortlistProfiles()
            : profileService.profiles;

        if (profileService.isLoading && profiles.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (profiles.isEmpty) {
          return Center(
            child: Text(
              isShortlisted
                  ? "No shortlisted profiles"
                  : "No suggestions found",
              style: TextStyle(
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.5),
                fontSize: 16,
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 120),
          itemCount: profiles.length,
          itemBuilder: (context, index) {
            return _buildProfileCard(profiles[index]);
          },
        );
      },
    );
  }

  Widget _buildProfileCard(UserProfile profile) {
    final profileService = Provider.of<ProfileService>(context);
    final isShortlisted = profileService.isShortlisted(profile.id);

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppStyles.cardShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProfileDetailScreen(userId: profile.id),
                  ),
                );
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image Section
                  Stack(
                    children: [
                      Image.network(
                        ApiService.instance.resolveUrl(
                          profile.photos.isNotEmpty ? profile.photos[0] : null,
                        ),
                        height: 220,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                      if (profile.isVerified)
                        Positioned(
                          top: 16,
                          left: 16,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.verified,
                              color: Colors.blue,
                              size: 20,
                            ),
                          ),
                        ),
                    ],
                  ),

                  // Details Section
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "${profile.name}, ${profile.age}",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            Text(
                              profile.income,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "${profile.occupation} • ${profile.education}",
                          style: TextStyle(
                            fontSize: 15,
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withValues(alpha: 0.6),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 18,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              profile.location,
                              style: const TextStyle(fontSize: 15),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            _buildChip(profile.caste ?? "Mali"),
                            const SizedBox(width: 8),
                            _buildChip(profile.motherTongue),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: IconButton(
                icon: Icon(
                  isShortlisted ? Icons.favorite : Icons.favorite_border,
                  color: isShortlisted ? Colors.red : Colors.white,
                  size: 32,
                ),
                onPressed: () {
                  profileService.toggleShortlist(profile.id);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    VoidCallback onSeeAll,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          TextButton(
            onPressed: onSeeAll,
            child: Text(
              "See All",
              style: TextStyle(
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.6),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
