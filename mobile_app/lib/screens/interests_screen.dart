import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/interest_service.dart';
import '../services/profile_service.dart';
import 'package:shared/shared.dart';
import 'profile_detail_screen.dart';
import 'payment_screen.dart';
import '../services/auth_service.dart';
import '../widgets/notification_badge.dart';
import '../services/chat_service.dart';
import 'chat_detail_screen.dart';

class InterestsScreen extends StatelessWidget {
  const InterestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "Interests Hub",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 0,
          scrolledUnderElevation: 0,
          foregroundColor: Theme.of(context).colorScheme.primary,
          surfaceTintColor: Colors.transparent,
          actions: const [
            Padding(
              padding: EdgeInsets.only(right: 16),
              child: NotificationBadge(),
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(64),
            child: Container(
              margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppStyles.radiusFull),
                boxShadow: AppStyles.cardShadow,
              ),
              child: TabBar(
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppStyles.radiusFull),
                  color: Theme.of(context).colorScheme.primary,
                ),
                labelColor: Colors.white,
                unselectedLabelColor: Theme.of(context).colorScheme.primary,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                tabs: const [
                  Tab(text: "Received"),
                  Tab(text: "Sent"),
                ],
              ),
            ),
          ),
        ),
        body: const TabBarView(
          children: [_ReceivedInterestsTab(), _SentInterestsTab()],
        ),
      ),
    );
  }
}

class _ReceivedInterestsTab extends StatelessWidget {
  const _ReceivedInterestsTab();

  @override
  Widget build(BuildContext context) {
    return Consumer2<InterestService, ProfileService>(
      builder: (context, interestService, profileService, child) {
        final interests = interestService.receivedInterests;

        if (interests.isEmpty) {
          return const Center(
            child: Text(
              "No interests received yet.",
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: interests.length,
          itemBuilder: (context, index) {
            final interest = interests[index];
            final profile = profileService.getProfileById(interest.senderId);

            if (profile == null) return const SizedBox.shrink();

            return _InterestCard(
              profile: profile,
              interest: interest,
              isReceived: true,
            );
          },
        );
      },
    );
  }
}

class _SentInterestsTab extends StatelessWidget {
  const _SentInterestsTab();

  @override
  Widget build(BuildContext context) {
    return Consumer2<InterestService, ProfileService>(
      builder: (context, interestService, profileService, child) {
        final interests = interestService.sentInterests;

        if (interests.isEmpty) {
          return const Center(
            child: Text(
              "You haven't sent any interests yet.",
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: interests.length,
          itemBuilder: (context, index) {
            final interest = interests[index];
            final profile = profileService.getProfileById(interest.receiverId);

            if (profile == null) return const SizedBox.shrink();

            return _InterestCard(
              profile: profile,
              interest: interest,
              isReceived: false,
            );
          },
        );
      },
    );
  }
}

class _InterestCard extends StatelessWidget {
  final UserProfile profile;
  final InterestModel interest;
  final bool isReceived;

  const _InterestCard({
    required this.profile,
    required this.interest,
    required this.isReceived,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppStyles.radiusL),
        boxShadow: AppStyles.cardShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppStyles.radiusL),
        child: InkWell(
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
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 35,
                  backgroundImage: profile.photos.isNotEmpty
                      ? NetworkImage(
                          ApiService.instance.resolveUrl(profile.photos[0]),
                        )
                      : null,
                  child: profile.photos.isEmpty
                      ? const Icon(Icons.person)
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profile.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${profile.age} yrs • ${profile.location.split(',')[0]}",
                        style: TextStyle(
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withValues(alpha: 0.6),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Interested on: ${DateFormatter.formatShortDate(interest.timestamp)}",
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withValues(alpha: 0.4),
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildStatusChip(),
                    ],
                  ),
                ),
                if (isReceived && interest.status == InterestStatus.pending)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildIconButton(
                        icon: Icons.check_circle_rounded,
                        color: Colors.green,
                        onPressed: () {
                          context.read<InterestService>().updateInterestStatus(
                            interest.id,
                            InterestStatus.accepted,
                          );
                        },
                      ),
                      const SizedBox(width: 8),
                      _buildIconButton(
                        icon: Icons.cancel_rounded,
                        color: Colors.red,
                        onPressed: () {
                          context.read<InterestService>().updateInterestStatus(
                            interest.id,
                            InterestStatus.declined,
                          );
                        },
                      ),
                    ],
                  ),
                if (isReceived && interest.status == InterestStatus.accepted)
                  _buildIconButton(
                    icon: Icons.chat_bubble_rounded,
                    color: Theme.of(context).colorScheme.primary,
                    onPressed: () {
                      final chatService = context.read<ChatService>();
                      final conversation = chatService.startConversation(
                        profile.id,
                        profile.name,
                        profile.photos.isNotEmpty ? profile.photos[0] : null,
                      );
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ChatDetailScreen(conversation: conversation),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: color),
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
      ),
    );
  }

  Widget _buildStatusChip() {
    Color color;
    String label;

    switch (interest.status) {
      case InterestStatus.pending:
        color = Colors.orange;
        label = "Pending";
        break;
      case InterestStatus.accepted:
        color = Colors.green;
        label = "Accepted";
        break;
      case InterestStatus.declined:
        color = Colors.red;
        label = "Declined";
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppStyles.radiusFull),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
