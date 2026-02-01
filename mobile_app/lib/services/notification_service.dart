import 'package:flutter/material.dart';
import '../models/notification_model.dart';

class NotificationService extends ChangeNotifier {
  final List<NotificationModel> _notifications = [];

  NotificationService() {
    _initializeMockNotifications();
  }

  List<NotificationModel> get notifications =>
      List.unmodifiable(_notifications);

  int get unreadCount =>
      _notifications.where((notification) => !notification.isRead).length;

  void _initializeMockNotifications() {
    // Add some mock notifications for demonstration
    _notifications.addAll([
      NotificationModel(
        id: '1',
        title: 'New Match Found!',
        message:
            'You have a new match with Priya Sharma. Check out their profile!',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        type: NotificationType.newMatch,
        relatedUserId: 'user_123',
      ),
      NotificationModel(
        id: '2',
        title: 'Profile View',
        message: 'Rahul Kumar viewed your profile',
        timestamp: DateTime.now().subtract(const Duration(hours: 5)),
        type: NotificationType.profileView,
        isRead: false,
        relatedUserId: 'user_456',
      ),
      NotificationModel(
        id: '3',
        title: 'Interest Received',
        message: 'Anjali Patel has shown interest in your profile',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        type: NotificationType.interestReceived,
        relatedUserId: 'user_789',
      ),
      NotificationModel(
        id: '4',
        title: 'Interest Accepted',
        message: 'Congratulations! Kavya accepted your interest request',
        timestamp: DateTime.now().subtract(const Duration(days: 2)),
        type: NotificationType.interestAccepted,
        isRead: true,
        relatedUserId: 'user_101',
      ),
      NotificationModel(
        id: '5',
        title: 'System Update',
        message:
            'New features added! Check out our enhanced matching algorithm',
        timestamp: DateTime.now().subtract(const Duration(days: 3)),
        type: NotificationType.system,
        isRead: true,
      ),
      NotificationModel(
        id: '6',
        title: 'New Message',
        message:
            'Siddharth Mali sent you a message: "I will be in Pune next weekend."',
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        type: NotificationType.message,
        isRead: false,
        relatedUserId: 'user_102',
      ),
      NotificationModel(
        id: '7',
        title: 'Profile Updated',
        message: 'Neha Deshmukh has updated their profile photos',
        timestamp: DateTime.now().subtract(const Duration(hours: 4)),
        type: NotificationType.system,
        isRead: false,
        relatedUserId: 'user_103',
      ),
      NotificationModel(
        id: '8',
        title: 'New Shortlist',
        message: 'A new user from Nashik has shortlisted your profile',
        timestamp: DateTime.now().subtract(const Duration(hours: 12)),
        type: NotificationType.profileView,
        relatedUserId: 'user_103',
      ),
    ]);
  }

  void markAsRead(String notificationId) {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      notifyListeners();
    }
  }

  void markAllAsRead() {
    for (int i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].copyWith(isRead: true);
    }
    notifyListeners();
  }

  void deleteNotification(String notificationId) {
    _notifications.removeWhere((n) => n.id == notificationId);
    notifyListeners();
  }

  IconData getIconForType(NotificationType type) {
    switch (type) {
      case NotificationType.newMatch:
        return Icons.favorite;
      case NotificationType.profileView:
        return Icons.visibility;
      case NotificationType.message:
        return Icons.message;
      case NotificationType.interestReceived:
        return Icons.thumb_up;
      case NotificationType.interestAccepted:
        return Icons.check_circle;
      case NotificationType.system:
        return Icons.info;
    }
  }
}
