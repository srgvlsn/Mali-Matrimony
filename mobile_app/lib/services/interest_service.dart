import 'package:flutter/foundation.dart';
import 'package:shared/shared.dart';
import 'auth_service.dart';

class InterestService extends ChangeNotifier {
  static final InterestService instance = InterestService._internal();
  InterestService._internal();
  factory InterestService() => instance;

  final List<InterestModel> _interests = [];
  bool _isLoading = false;

  List<InterestModel> get receivedInterests {
    final curUser = AuthService.instance.currentUser;
    if (curUser == null) return [];
    return _interests.where((i) => i.receiverId == curUser.id).toList();
  }

  List<InterestModel> get sentInterests {
    final curUser = AuthService.instance.currentUser;
    if (curUser == null) return [];
    return _interests.where((i) => i.senderId == curUser.id).toList();
  }

  bool get isLoading => _isLoading;

  int get unreadReceivedCount {
    return receivedInterests
        .where((i) => i.status == InterestStatus.pending)
        .length;
  }

  Future<void> fetchInterests() async {
    final curUser = AuthService.instance.currentUser;
    if (curUser == null) return;

    _isLoading = true;
    notifyListeners();

    final response = await BackendService.instance.getInterests(curUser.id);
    if (response.success) {
      _interests.clear();
      _interests.addAll(response.data ?? []);
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> sendInterest(String userId) async {
    final curUser = AuthService.instance.currentUser;
    if (curUser == null) return false;

    final response = await BackendService.instance.sendInterest(
      curUser.id,
      userId,
    );
    if (response.success) {
      await fetchInterests(); // Refresh list after sending
      return true;
    }
    return false;
  }

  Future<void> updateInterestStatus(
    String interestId,
    InterestStatus newStatus,
  ) async {
    final response = await BackendService.instance.updateInterestStatus(
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
    final curUser = AuthService.instance.currentUser;
    if (curUser == null) return null;

    try {
      final interest = _interests.firstWhere(
        (i) =>
            (i.senderId == curUser.id && i.receiverId == userId) ||
            (i.senderId == userId && i.receiverId == curUser.id),
      );
      return interest.status;
    } catch (_) {
      return null;
    }
  }

  bool hasInterestWith(String userId) {
    final curUser = AuthService.instance.currentUser;
    if (curUser == null) return false;

    return _interests.any(
      (i) =>
          (i.senderId == curUser.id && i.receiverId == userId) ||
          (i.senderId == userId && i.receiverId == curUser.id),
    );
  }
}
