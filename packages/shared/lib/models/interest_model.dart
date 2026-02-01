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
}
