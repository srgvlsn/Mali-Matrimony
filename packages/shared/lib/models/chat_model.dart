class ChatMessage {
  final String id;
  final String senderId;
  final String receiverId;
  final String text;
  final DateTime timestamp;
  final bool isMe;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.text,
    required this.timestamp,
    required this.isMe,
  });

  factory ChatMessage.fromMap(Map<String, dynamic> map, String currentUserId) {
    return ChatMessage(
      id: map['id'],
      senderId: map['sender_id'],
      receiverId: map['receiver_id'],
      text: map['text'],
      timestamp: DateTime.parse(map['timestamp']),
      isMe: map['sender_id'] == currentUserId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sender_id': senderId,
      'receiver_id': receiverId,
      'text': text,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

class Conversation {
  final String id;
  final String otherUserId;
  final String otherUserName;
  final String? otherUserPhoto;
  final String lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;

  Conversation({
    required this.id,
    required this.otherUserId,
    required this.otherUserName,
    this.otherUserPhoto,
    required this.lastMessage,
    required this.lastMessageTime,
    this.unreadCount = 0,
  });

  factory Conversation.fromMap(Map<String, dynamic> map) {
    return Conversation(
      id: map['id'],
      otherUserId: map['other_user_id'],
      otherUserName: map['other_user_name'],
      otherUserPhoto: map['other_user_photo'],
      lastMessage: map['last_message'],
      lastMessageTime: DateTime.parse(map['last_message_time']),
      unreadCount: map['unread_count'] ?? 0,
    );
  }
}
