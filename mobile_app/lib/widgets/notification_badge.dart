import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared/shared.dart';
import '../services/notification_service.dart';
import '../services/auth_service.dart';
import '../services/profile_service.dart';
import '../screens/profile_detail_screen.dart';
import '../screens/payment_screen.dart';
import '../screens/settings_screen.dart';

class NotificationBadge extends StatelessWidget {
  final VoidCallback? onProfileVerified;
  const NotificationBadge({super.key, this.onProfileVerified});

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationService>(
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
            if (notificationService.unreadCount > 0)
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
    );
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
                                      child: _buildEmptyNotifications(context),
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

  Widget _buildEmptyNotifications(BuildContext context) {
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

          final navigator = Navigator.of(context, rootNavigator: true);

          if (notification.type == NotificationType.profileVerified ||
              notification.title == "Profile Verified") {
            Navigator.of(context).pop(); // Close dialog
            if (onProfileVerified != null) onProfileVerified!();

            if (wasUnread) {
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
          } else if (notification.type == NotificationType.premiumMembership ||
              notification.title.contains("Premium")) {
            Navigator.of(context).pop(); // Close dialog

            // Short delay to ensure dialog closure is processed
            Future.delayed(const Duration(milliseconds: 100), () {
              navigator.push(
                MaterialPageRoute(
                  builder: (_) =>
                      const SettingsScreen(highlightMembership: true),
                ),
              );
            });
          } else if (notification.relatedUserId != null) {
            Navigator.of(context).pop(); // Close dialog
            final authService = Provider.of<AuthService>(
              context,
              listen: false,
            );
            if (authService.isPremiumUser) {
              navigator.push(
                MaterialPageRoute(
                  builder: (_) =>
                      ProfileDetailScreen(userId: notification.relatedUserId!),
                ),
              );
            } else {
              navigator.push(
                MaterialPageRoute(builder: (_) => const PaymentScreen()),
              );
            }
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
}
