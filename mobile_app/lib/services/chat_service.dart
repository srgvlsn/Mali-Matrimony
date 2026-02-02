import 'package:flutter/foundation.dart';
import 'package:shared/shared.dart';

class ChatService extends ChangeNotifier {
  static final ChatService instance = ChatService._internal();
  ChatService._internal();
  factory ChatService() => instance;

  final List<Conversation> _conversations = [];
  final Map<String, List<ChatMessage>> _messages = {};

  List<Conversation> get conversations => _conversations;

  int get totalUnreadCount {
    return _conversations.fold(0, (sum, item) => sum + item.unreadCount);
  }

  List<ChatMessage> getMessages(String conversationId) {
    return _messages[conversationId] ?? [];
  }

  void sendMessage(String conversationId, String text) {
    final message = ChatMessage(
      id: DateTime.now().toString(),
      senderId: 'me',
      text: text,
      timestamp: DateTime.now(),
      isMe: true,
    );

    if (!_messages.containsKey(conversationId)) {
      _messages[conversationId] = [];
    }
    _messages[conversationId]!.add(message);

    // Update last message in conversation
    final index = _conversations.indexWhere((c) => c.id == conversationId);
    if (index != -1) {
      final old = _conversations[index];
      _conversations[index] = Conversation(
        id: old.id,
        otherUserId: old.otherUserId,
        otherUserName: old.otherUserName,
        otherUserPhoto: old.otherUserPhoto,
        lastMessage: text,
        lastMessageTime: DateTime.now(),
        unreadCount: 0,
      );
    }

    notifyListeners();
  }

  Conversation startConversation(
    String otherUserId,
    String otherUserName,
    String otherUserPhoto,
  ) {
    // Check if conversation already exists
    final existingIndex = _conversations.indexWhere(
      (c) => c.otherUserId == otherUserId,
    );

    if (existingIndex != -1) {
      return _conversations[existingIndex];
    }

    // Create new conversation
    final newConversation = Conversation(
      id: DateTime.now().toIso8601String(),
      otherUserId: otherUserId,
      otherUserName: otherUserName,
      otherUserPhoto: otherUserPhoto,
      lastMessage: '',
      lastMessageTime: DateTime.now(),
      unreadCount: 0,
    );

    _conversations.add(newConversation);
    notifyListeners();
    return newConversation;
  }
}
