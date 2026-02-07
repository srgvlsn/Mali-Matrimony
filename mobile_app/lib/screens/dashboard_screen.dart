import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import 'blocked_conversations_screen.dart';
import 'archived_conversations_screen.dart';
import '../services/chat_service.dart';
import '../services/interest_service.dart';
import 'profile_detail_screen.dart';
import 'chat_list_screen.dart';
import 'user_profile_screen.dart';
import 'interests_screen.dart';
import 'payment_screen.dart';
import '../services/profile_service.dart';
import 'package:shared/shared.dart';
import '../widgets/notification_badge.dart';
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
      context.read<InterestService>().fetchInterests();
    });
  }

  late final List<Widget> _screens = [
    _HomeView(
      onNavigateToInterests: () {
        setState(() => _selectedIndex = 1);
      },
    ),
    const InterestsScreen(),
    const ChatListScreen(),
    const UserProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final chatService = context.watch<ChatService>();
    final isSelectionMode = chatService.isSelectionMode && _selectedIndex == 2;

    return Scaffold(
      extendBody: true,
      appBar: _selectedIndex == 1
          ? null
          : AppBar(
              title: isSelectionMode
                  ? Text(
                      '${chatService.selectedConversationIds.length} Selected',
                    )
                  : Text(
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
              leading: isSelectionMode
                  ? IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: chatService.clearSelection,
                    )
                  : null,
              systemOverlayStyle: const SystemUiOverlayStyle(
                statusBarColor: Colors.transparent,
                statusBarIconBrightness: Brightness.dark,
                systemNavigationBarColor: Colors.transparent,
                systemNavigationBarIconBrightness: Brightness.dark,
              ),
              actions: [
                if (!isSelectionMode)
                  NotificationBadge(
                    onProfileVerified: () {
                      setState(() => _selectedIndex = 3);
                    },
                  ),
                if (_selectedIndex == 2) // Chat Tab
                  if (isSelectionMode)
                    PopupMenuButton<String>(
                      icon: Icon(
                        Icons.more_vert_rounded,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      onSelected: (value) {
                        if (value == 'archive') {
                          chatService.archiveSelectedConversations();
                        } else if (value == 'read') {
                          // chatService.markSelectedAsRead();
                          chatService.clearSelection();
                        }
                      },
                      itemBuilder: (context) => [
                        _buildPopupMenuItem(Icons.archive_outlined, "Archive"),
                        // _buildPopupMenuItem(Icons.mark_email_read_outlined, "Mark as Read"),
                      ],
                    )
                  else
                    PopupMenuButton<String>(
                      icon: Icon(
                        Icons.more_vert_rounded,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      onSelected: (value) {
                        if (value == 'blocked') {
                          _showBlockedConversations();
                        } else if (value == 'archived') {
                          _showArchivedConversations();
                        }
                      },
                      itemBuilder: (context) => [
                        _buildPopupMenuItem(Icons.block_outlined, "Blocked"),
                        _buildPopupMenuItem(Icons.archive_outlined, "Archived"),
                      ],
                    ),
                if (_selectedIndex == 3) // Profile Tab
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

  void _showBlockedConversations() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const BlockedConversationsScreen(),
      ),
    );
  }

  void _showArchivedConversations() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ArchivedConversationsScreen(),
      ),
    );
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
  final VoidCallback? onNavigateToInterests;
  const _HomeView({this.onNavigateToInterests});

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
          borderRadius: BorderRadius.circular(AppStyles.radiusL),
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
                  (analytics?.totalViews ?? 0).toString(),
                  Icons.remove_red_eye_outlined,
                ),
                _buildReachDivider(),
                _buildReachItem(
                  "Received",
                  (analytics?.interestsReceived ?? 0).toString(),
                  Icons.star_outline_rounded,
                  onTap: widget.onNavigateToInterests,
                ),
                _buildReachDivider(),
                _buildReachItem(
                  "Sent",
                  (analytics?.interestsSent ?? 0).toString(),
                  Icons.send_rounded,
                  onTap: widget.onNavigateToInterests,
                ),
                _buildReachDivider(),
                _buildReachItem(
                  "Shortlists",
                  (analytics?.shortlistedBy ?? 0).toString(),
                  Icons.favorite_border_rounded,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReachItem(
    String label,
    String value,
    IconData icon, {
    VoidCallback? onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
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
        ),
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
        borderRadius: BorderRadius.circular(AppStyles.radiusL),
        boxShadow: AppStyles.cardShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppStyles.radiusL),
        child: Stack(
          children: [
            InkWell(
              onTap: () {
                final authService = Provider.of<AuthService>(
                  context,
                  listen: false,
                );
                if (authService.isPremiumUser) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProfileDetailScreen(userId: profile.id),
                    ),
                  );
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const PaymentScreen()),
                  );
                }
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
