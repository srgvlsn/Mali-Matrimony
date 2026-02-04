import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:shared/shared.dart';
import 'auth_service.dart';
import 'notification_service.dart';

class ChatService extends ChangeNotifier {
  static final ChatService instance = ChatService._internal();
  ChatService._internal();
  factory ChatService() => instance;

  List<Conversation> _conversations = [];
  final Map<String, List<ChatMessage>> _messages = {};
  final Set<String> _typingUsers = {};
  bool _isLoading = false;

  List<Conversation> get conversations => _conversations;
  bool get isLoading => _isLoading;

  int get totalUnreadCount {
    return _conversations.fold(0, (sum, item) => sum + item.unreadCount);
  }

  Future<void> fetchConversations() async {
    final user = AuthService.instance.currentUser;
    if (user == null) return;

    _isLoading = true;
    notifyListeners();

    final response = await BackendService.instance.getConversations(user.id);
    if (response.success) {
      _conversations = response.data ?? [];
    }

    _isLoading = false;
    notifyListeners();
  }

  List<ChatMessage> getMessages(String otherUserId) {
    return _messages[otherUserId] ?? [];
  }

  Future<void> fetchMessages(String otherUserId) async {
    final user = AuthService.instance.currentUser;
    if (user == null) return;

    final response = await BackendService.instance.getChatMessages(
      user.id,
      otherUserId,
    );
    if (response.success) {
      _messages[otherUserId] = response.data ?? [];
      notifyListeners();
    }
  }

  Future<void> sendMessage(String otherUserId, String text) async {
    final user = AuthService.instance.currentUser;
    if (user == null) return;

    // Optimistic update
    final tempMsg = ChatMessage(
      id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
      senderId: user.id,
      receiverId: otherUserId,
      text: text,
      timestamp: DateTime.now(),
      isMe: true,
    );

    if (!_messages.containsKey(otherUserId)) {
      _messages[otherUserId] = [];
    }
    _messages[otherUserId]!.add(tempMsg);
    notifyListeners();

    final response = await BackendService.instance.sendChatMessage(
      user.id,
      otherUserId,
      text,
    );

    if (response.success && response.data != null) {
      // Replace temp message with real one from backend
      final index = _messages[otherUserId]!.indexOf(tempMsg);
      if (index != -1) {
        _messages[otherUserId]![index] = response.data!;
      }

      // Update conversations list as well
      await fetchConversations();
    }
    notifyListeners();
  }

  /// Called when a new message arrives via WebSocket
  void handleIncomingMessage(ChatMessage message) {
    final otherId = message.senderId; // For receiver, other is the sender

    if (!_messages.containsKey(otherId)) {
      _messages[otherId] = [];
    }

    // Check if message already exists (to avoid duplicates from fetch + socket)
    if (!_messages[otherId]!.any((m) => m.id == message.id)) {
      _messages[otherId]!.add(message);

      // Refresh conversations to update last message and unread count
      fetchConversations();
      notifyListeners();
    }
  }

  Conversation startConversation(
    String otherUserId,
    String otherUserName,
    String? otherUserPhoto,
  ) {
    // Check if conversation already exists
    final existingIndex = _conversations.indexWhere(
      (c) => c.otherUserId == otherUserId,
    );

    if (existingIndex != -1) {
      return _conversations[existingIndex];
    }

    // Create new temporary conversation
    final newConversation = Conversation(
      id: 'new_${DateTime.now().millisecondsSinceEpoch}',
      otherUserId: otherUserId,
      otherUserName: otherUserName,
      otherUserPhoto: otherUserPhoto,
      lastMessage: '',
      lastMessageTime: DateTime.now(),
      unreadCount: 0,
    );

    _conversations.insert(0, newConversation);
    notifyListeners();
    return newConversation;
  }

  void handleTypingEvent(Map<String, dynamic> data) {
    final senderId = data['sender_id'];
    final type = data['type'];
    if (senderId == null) return;

    if (type == 'typing_started') {
      _typingUsers.add(senderId);
    } else {
      _typingUsers.remove(senderId);
    }
    notifyListeners();
  }

  bool isUserTyping(String userId) {
    return _typingUsers.contains(userId);
  }

  void sendTypingStatus(String otherUserId, bool isTyping) {
    try {
      NotificationService.instance.sendTypingEvent(otherUserId, isTyping);
    } catch (e) {
      debugPrint("Error sending typing status: $e");
    }
  }

  Future<ChatMessage?> sendImageMessage(
    String otherUserId,
    File imageFile,
  ) async {
    final user = AuthService.instance.currentUser;
    if (user == null) return null;

    try {
      final bytes = await imageFile.readAsBytes();
      final fileName = imageFile.path.split('/').last;

      final uploadResponse = await BackendService.instance.uploadChatAttachment(
        bytes,
        fileName,
      );

      if (!uploadResponse.success || uploadResponse.data == null) {
        return null;
      }
      final attachmentUrl = uploadResponse.data!;

      // Optimistic update for image? Maybe just wait for response to avoid complex local handling of pending images
      // Or show a placeholder. For now, simple await.

      final response = await BackendService.instance.sendChatMessage(
        user.id,
        otherUserId,
        "Image",
        attachmentUrl: attachmentUrl,
        attachmentType: "image",
      );

      if (response.success && response.data != null) {
        handleIncomingMessage(response.data!);
        return response.data!;
      }
    } catch (e) {
      debugPrint("Error sending image: $e");
    }
    return null;
  }
}
