class ChatMessage {
  final String id;
  final String senderId;
  final String receiverId;
  final String text;
  final DateTime timestamp;
  final bool isMe;
  final bool isRead;
  final String? attachmentUrl;
  final String? attachmentType;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.text,
    required this.timestamp,
    required this.isMe,
    required this.isRead,
    this.attachmentUrl,
    this.attachmentType,
  });

  factory ChatMessage.fromMap(Map<String, dynamic> map, String currentUserId) {
    return ChatMessage(
      id: map['id'],
      senderId: map['sender_id'],
      receiverId: map['receiver_id'],
      text: map['text'],
      timestamp: DateTime.parse(map['timestamp']),
      isMe: map['sender_id'] == currentUserId,
      isRead: map['is_read'] == true,
      attachmentUrl: map['attachment_url'],
      attachmentType: map['attachment_type'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sender_id': senderId,
      'receiver_id': receiverId,
      'text': text,
      'timestamp': timestamp.toIso8601String(),
      'attachment_url': attachmentUrl,
      'attachment_type': attachmentType,
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
  final bool isLastMessageMe;
  final bool isBlocked;

  Conversation({
    required this.id,
    required this.otherUserId,
    required this.otherUserName,
    this.otherUserPhoto,
    required this.lastMessage,
    required this.lastMessageTime,
    this.unreadCount = 0,
    required this.isLastMessageMe,
    this.isBlocked = false,
  });

  factory Conversation.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return Conversation(
        id: '',
        otherUserId: '',
        otherUserName: 'Unknown',
        lastMessage: '',
        lastMessageTime: DateTime.now(),
        unreadCount: 0,
        isLastMessageMe: false,
        isBlocked: false,
      );
    }
    return Conversation(
      id: map['id'] ?? '',
      otherUserId: map['other_user_id'] ?? '',
      otherUserName: map['other_user_name'] ?? 'Unknown',
      otherUserPhoto: map['other_user_photo'],
      lastMessage: map['last_message'] ?? '',
      lastMessageTime: map['last_message_time'] != null
          ? DateTime.parse(map['last_message_time'])
          : DateTime.now(),
      unreadCount: (map['unread_count'] as num?)?.toInt() ?? 0,
      isLastMessageMe: map['is_last_message_me'] == true,
      isBlocked: map['is_blocked'] == true,
    );
  }
}
