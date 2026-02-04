enum InterestStatus { pending, accepted, declined }

class InterestModel {
  final String id;
  final String senderId;
  final String receiverId;
  final InterestStatus status;
  final DateTime timestamp;

  InterestModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
    this.status = InterestStatus.pending,
    required this.timestamp,
  });

  InterestModel copyWith({
    String? id,
    String? senderId,
    String? receiverId,
    InterestStatus? status,
    DateTime? timestamp,
  }) {
    return InterestModel(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      status: status ?? this.status,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sender_id': senderId,
      'receiver_id': receiverId,
      'status': status.name,
      'timestamp': timestamp,
    };
  }

  static InterestModel fromMap(Map<String, dynamic> map) {
    return InterestModel(
      id: map['id'] as String,
      senderId: map['sender_id'] as String,
      receiverId: map['receiver_id'] as String,
      status: InterestStatus.values.firstWhere(
        (e) => e.name == (map['status'] as String),
      ),
      timestamp: DateTime.parse(map['timestamp'] as String),
    );
  }
}
