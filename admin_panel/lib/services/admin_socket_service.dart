import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:shared/shared.dart';
import 'package:flutter/foundation.dart';

class AdminSocketEvent {
  final String type;
  final String userId;
  final String userName;
  final Map<String, dynamic> extraData;

  AdminSocketEvent({
    required this.type,
    required this.userId,
    required this.userName,
    this.extraData = const {},
  });
}

class AdminSocketService extends ChangeNotifier {
  WebSocketChannel? _channel;
  bool _isConnected = false;

  // Stream controllers for events
  final _eventController = StreamController<AdminSocketEvent>.broadcast();
  Stream<AdminSocketEvent> get eventStream => _eventController.stream;

  static final AdminSocketService instance = AdminSocketService._internal();
  AdminSocketService._internal();

  bool get isConnected => _isConnected;

  void connect() {
    if (_isConnected) return;

    // We use a fixed admin ID for simplicity, or we could pass the logged-in admin ID
    const adminId = "admin_global";
    final wsUrl = ApiService.instance.baseUrl
        .replaceFirst('http', 'ws')
        .replaceFirst('8000', '8000/ws/$adminId');

    try {
      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
      _isConnected = true;
      debugPrint("✅ Admin WebSocket connected to: $wsUrl");
      notifyListeners();

      _channel!.stream.listen(
        (message) {
          _handleMessage(message);
        },
        onDone: () {
          _isConnected = false;
          notifyListeners();
          // Attempt reconnect after delay
          Future.delayed(const Duration(seconds: 5), () => connect());
        },
        onError: (error) {
          debugPrint("Admin WebSocket Error: $error");
          _isConnected = false;
          notifyListeners();
        },
      );
    } catch (e) {
      debugPrint("Could not connect to Admin WebSocket: $e");
    }
  }

  void _handleMessage(dynamic message) {
    debugPrint("📬 Admin WebSocket Received: $message");
    try {
      final data = jsonDecode(message);
      final type = data['type'];
      final userId = data['user_id'] ?? 'unknown';
      final userName = data['user_name'] ?? 'A user';

      // Broad filter for all admin-relevant events
      final adminEvents = [
        'payment_completed',
        'profile_updated',
        'user_registered',
        'interest_sent',
        'interest_accepted',
        'shortlist_toggled',
        'profile_deleted',
      ];

      if (adminEvents.contains(type)) {
        debugPrint("✨ Processing $type event for $userName");
        _eventController.add(
          AdminSocketEvent(
            type: type,
            userId: userId,
            userName: userName,
            extraData: data,
          ),
        );
      }
    } catch (e) {
      debugPrint("Error parsing Admin WebSocket message: $e");
    }
  }

  void disconnect() {
    _channel?.sink.close();
    _isConnected = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _eventController.close();
    super.dispose();
  }
}
