import 'package:flutter/material.dart';
import 'package:shared/shared.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:convert';
import 'auth_service.dart';
import 'interest_service.dart';
import 'profile_service.dart';
import 'chat_service.dart';

class NotificationService extends ChangeNotifier {
  final List<NotificationModel> _notifications = [];

  NotificationService() {
    fetchForCurrentUser();
  }

  WebSocketChannel? _channel;
  String? _lastSeenNotificationId;

  List<NotificationModel> get notifications =>
      List.unmodifiable(_notifications);

  int get unreadCount =>
      _notifications.where((notification) => !notification.isRead).length;

  bool get showIndicator {
    if (_notifications.isEmpty) return false;
    return _notifications.first.id != _lastSeenNotificationId &&
        unreadCount > 0;
  }

  void clearIndicator() {
    if (_notifications.isNotEmpty) {
      _lastSeenNotificationId = _notifications.first.id;
      notifyListeners();
    }
  }

  Future<void> fetchForCurrentUser() async {
    final user = AuthService.instance.currentUser;
    if (user != null) {
      await fetchNotifications(user.id);
      _initWebSocket(user.id);
    } else {
      _notifications.clear();
      _closeWebSocket();
      notifyListeners();
    }
  }

  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 3;

  void _initWebSocket(String userId) {
    if (_channel != null) return; // Already connected
    if (_reconnectAttempts >= _maxReconnectAttempts) {
      debugPrint('WebSocket: Max reconnect attempts reached, giving up');
      return;
    }

    try {
      final wsUrl = ApiService.instance.wsUrl;
      // Clean the userId to remove any fragments
      final cleanUserId = userId.split('#').first;
      final uri = Uri.parse('$wsUrl/ws/$cleanUserId');

      debugPrint(
        'Connecting to WebSocket: $uri (attempt ${_reconnectAttempts + 1})',
      );

      _channel = WebSocketChannel.connect(uri);

      // Reset attempts on successful connection
      _channel!.ready
          .then((_) {
            debugPrint('WebSocket connected successfully');
            _reconnectAttempts = 0;
          })
          .catchError((e) {
            debugPrint('WebSocket connection failed: $e');
            _channel = null;
            _reconnectAttempts++;
            // Don't auto-reconnect on connection failure
          });

      _channel!.stream.listen(
        (message) {
          try {
            final data = json.decode(message);
            if (data['type'] == 'new_notification') {
              fetchNotifications(cleanUserId);
              InterestService.instance.fetchInterests();
              if (data['title'] == 'Profile Verified') {
                AuthService.instance.refreshProfile();
              }
            } else if (data['type'] == 'new_message') {
              final chatMsg = ChatMessage.fromMap(data['data'], cleanUserId);
              ChatService.instance.handleIncomingMessage(chatMsg);
            } else if (data['type'] == 'shortlist_updated') {
              ProfileService.instance.fetchProfiles();
            }
          } catch (e) {
            debugPrint('Error parsing WebSocket message: $e');
          }
        },
        onError: (error) {
          debugPrint('WebSocket stream error: $error');
          _channel = null;
        },
        onDone: () {
          debugPrint('WebSocket closed');
          _channel = null;
          _reconnect(cleanUserId);
        },
        cancelOnError: true,
      );
    } catch (e) {
      debugPrint('WebSocket init error: $e');
      _channel = null;
    }
  }

  void _reconnect(String userId) {
    _channel = null;
    _reconnectAttempts++;
    if (_reconnectAttempts >= _maxReconnectAttempts) {
      debugPrint(
        'WebSocket: Stopped reconnecting after $_maxReconnectAttempts attempts',
      );
      return;
    }
    Future.delayed(Duration(seconds: 10 * _reconnectAttempts), () {
      final user = AuthService.instance.currentUser;
      if (user != null && user.id == userId) {
        _initWebSocket(userId);
      }
    });
  }

  void _closeWebSocket() {
    _channel?.sink.close();
    _channel = null;
  }

  Future<void> fetchNotifications(String userId) async {
    final response = await BackendService.instance.getNotifications(userId);
    if (response.success && response.data != null) {
      _notifications.clear();
      _notifications.addAll(response.data!);
      notifyListeners();
    }
  }

  Future<void> markAsRead(String notificationId) async {
    final response = await BackendService.instance.markNotificationAsRead(
      notificationId,
    );
    if (response.success) {
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        _notifications[index] = _notifications[index].copyWith(isRead: true);
        notifyListeners();
      }
    }
  }

  Future<void> markAllAsRead() async {
    for (var notification in _notifications.where((n) => !n.isRead)) {
      await markAsRead(notification.id);
    }
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

  @override
  void dispose() {
    _closeWebSocket();
    super.dispose();
  }
}
