import 'package:flutter/foundation.dart';
import 'package:shared/shared.dart';

class InterestService extends ChangeNotifier {
  static final InterestService instance = InterestService._internal();
  InterestService._internal();
  factory InterestService() => instance;

  final List<InterestModel> _interests = [
    // Mock Received Interests
    InterestModel(
      id: 'int_1',
      senderId: 'user_123', // Priya Sharma
      receiverId: 'me',
      status: InterestStatus.pending,
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
    ),
    InterestModel(
      id: 'int_2',
      senderId: 'user_102', // Siddharth Mali
      receiverId: 'me',
      status: InterestStatus.accepted,
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
    ),
    // Mock Sent Interests
    InterestModel(
      id: 'int_3',
      senderId: 'me',
      receiverId: 'user_789', // Anjali Patel
      status: InterestStatus.pending,
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
    ),
  ];

  List<InterestModel> get receivedInterests =>
      _interests.where((i) => i.receiverId == 'me').toList();

  List<InterestModel> get sentInterests =>
      _interests.where((i) => i.senderId == 'me').toList();

  void sendInterest(String userId) {
    if (_interests.any((i) => i.senderId == 'me' && i.receiverId == userId)) {
      return;
    }

    _interests.add(
      InterestModel(
        id: DateTime.now().toIso8601String(),
        senderId: 'me',
        receiverId: userId,
        timestamp: DateTime.now(),
      ),
    );
    notifyListeners();
  }

  void updateInterestStatus(String interestId, InterestStatus newStatus) {
    final index = _interests.indexWhere((i) => i.id == interestId);
    if (index != -1) {
      _interests[index] = _interests[index].copyWith(status: newStatus);
      notifyListeners();
    }
  }

  InterestStatus? getStatusWithUser(String userId) {
    try {
      final interest = _interests.firstWhere(
        (i) =>
            (i.senderId == 'me' && i.receiverId == userId) ||
            (i.senderId == userId && i.receiverId == 'me'),
      );
      return interest.status;
    } catch (_) {
      return null;
    }
  }

  bool hasInterestWith(String userId) {
    return _interests.any(
      (i) =>
          (i.senderId == 'me' && i.receiverId == userId) ||
          (i.senderId == userId && i.receiverId == 'me'),
    );
  }
}

