import 'package:flutter/foundation.dart';
import 'package:shared/shared.dart';

class InterestService extends ChangeNotifier {
  static final InterestService instance = InterestService._internal();
  InterestService._internal();
  factory InterestService() => instance;

  List<InterestModel> _interests = [];
  bool _isLoading = false;

  List<InterestModel> get receivedInterests =>
      _interests.where((i) => i.receiverId == 'user_456').toList();

  List<InterestModel> get sentInterests =>
      _interests.where((i) => i.senderId == 'user_456').toList();

  bool get isLoading => _isLoading;

  Future<void> fetchInterests() async {
    _isLoading = true;
    notifyListeners();

    final response = await MockBackend.instance.getInterests();
    if (response.success && response.data != null) {
      _interests = response.data!;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> sendInterest(String userId) async {
    final response = await MockBackend.instance.sendInterest(userId);
    if (response.success && response.data != null) {
      _interests.add(response.data!);
      notifyListeners();
    }
  }

  Future<void> updateInterestStatus(
    String interestId,
    InterestStatus newStatus,
  ) async {
    final response = await MockBackend.instance.updateInterestStatus(
      interestId,
      newStatus,
    );
    if (response.success) {
      final index = _interests.indexWhere((i) => i.id == interestId);
      if (index != -1) {
        _interests[index] = _interests[index].copyWith(status: newStatus);
        notifyListeners();
      }
    }
  }

  InterestStatus? getStatusWithUser(String userId) {
    try {
      final interest = _interests.firstWhere(
        (i) =>
            (i.senderId == 'user_456' && i.receiverId == userId) ||
            (i.senderId == userId && i.receiverId == 'user_456'),
      );
      return interest.status;
    } catch (_) {
      return null;
    }
  }

  bool hasInterestWith(String userId) {
    return _interests.any(
      (i) =>
          (i.senderId == 'user_456' && i.receiverId == userId) ||
          (i.senderId == userId && i.receiverId == 'user_456'),
    );
  }
}
