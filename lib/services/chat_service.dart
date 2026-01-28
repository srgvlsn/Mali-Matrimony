import 'package:flutter/foundation.dart';

class ChatMessage {
  final String id;
  final String senderId;
  final String text;
  final DateTime timestamp;
  final bool isMe;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.text,
    required this.timestamp,
    required this.isMe,
  });
}

class Conversation {
  final String id;
  final String otherUserId;
  final String otherUserName;
  final String otherUserPhoto;
  final String lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;

  Conversation({
    required this.id,
    required this.otherUserId,
    required this.otherUserName,
    required this.otherUserPhoto,
    required this.lastMessage,
    required this.lastMessageTime,
    this.unreadCount = 0,
  });
}

class ChatService extends ChangeNotifier {
  static final ChatService instance = ChatService._internal();
  ChatService._internal();

  final List<Conversation> _conversations = [
    Conversation(
      id: 'conv_1',
      otherUserId: 'user_123',
      otherUserName: 'Priya Sharma',
      otherUserPhoto:
          'https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=1000&auto=format&fit=crop',
      lastMessage: 'Hi, I liked your profile!',
      lastMessageTime: DateTime.now().subtract(const Duration(minutes: 15)),
      unreadCount: 2,
    ),
    Conversation(
      id: 'conv_2',
      otherUserId: 'user_789',
      otherUserName: 'Anjali Patel',
      otherUserPhoto:
          'https://images.unsplash.com/photo-1531123897727-8f129e16fd3c?q=80&w=1000&auto=format&fit=crop',
      lastMessage: 'Let me talk to my parents first.',
      lastMessageTime: DateTime.now().subtract(const Duration(hours: 2)),
    ),
  ];

  final Map<String, List<ChatMessage>> _messages = {
    'conv_1': [
      ChatMessage(
        id: 'msg_1',
        senderId: 'user_123',
        text: 'Hi there!',
        timestamp: DateTime.now().subtract(const Duration(minutes: 20)),
        isMe: false,
      ),
      ChatMessage(
        id: 'msg_2',
        senderId: 'user_123',
        text: 'I liked your profile!',
        timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
        isMe: false,
      ),
    ],
  };

  List<Conversation> get conversations => _conversations;

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
}
