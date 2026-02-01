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
  factory ChatService() => instance;

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
    Conversation(
      id: 'conv_3',
      otherUserId: 'user_102',
      otherUserName: 'Siddharth Mali',
      otherUserPhoto:
          'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?q=80&w=1000&auto=format&fit=crop',
      lastMessage: 'I will be in Pune next weekend.',
      lastMessageTime: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    Conversation(
      id: 'conv_4',
      otherUserId: 'user_103',
      otherUserName: 'Neha Deshmukh',
      otherUserPhoto:
          'https://images.unsplash.com/photo-1544005313-94ddf0286df2?q=80&w=1000&auto=format&fit=crop',
      lastMessage: 'Hello! Thanks for the interest.',
      lastMessageTime: DateTime.now().subtract(const Duration(days: 1)),
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
    'conv_3': [
      ChatMessage(
        id: 'msg_31',
        senderId: 'user_102',
        text: 'Hi, are you based in Pune or Bangalore?',
        timestamp: DateTime.now().subtract(const Duration(hours: 6)),
        isMe: false,
      ),
      ChatMessage(
        id: 'msg_32',
        senderId: 'me',
        text: 'I am based in Pune, but I visit Bangalore often for work.',
        timestamp: DateTime.now().subtract(const Duration(hours: 5)),
        isMe: true,
      ),
      ChatMessage(
        id: 'msg_33',
        senderId: 'user_102',
        text: 'That is great! I will be in Pune next weekend.',
        timestamp: DateTime.now().subtract(const Duration(hours: 5)),
        isMe: false,
      ),
    ],
    'conv_4': [
      ChatMessage(
        id: 'msg_41',
        senderId: 'user_103',
        text: 'Hello! Thanks for the interest.',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
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
