import 'package:flutter/foundation.dart';
import 'package:shared/shared.dart';
import 'auth_service.dart';

class ProfileService extends ChangeNotifier {
  static final ProfileService instance = ProfileService._internal();
  ProfileService._internal();
  factory ProfileService() => instance;

  List<UserProfile> _profiles = [];
  Set<String> _shortlistedIds = {};
  UserAnalytics? _analytics;
  bool _isLoading = false;

  List<UserProfile> get profiles {
    final currentUser = AuthService.instance.currentUser;
    if (currentUser == null) return _profiles;
    return _profiles.where((p) => p.id != currentUser.id).toList();
  }

  Set<String> get shortlistedIds => _shortlistedIds;
  UserAnalytics? get analytics => _analytics;
  bool get isLoading => _isLoading;

  /// Fetch profiles from PostgreSQL
  Future<void> fetchProfiles() async {
    _isLoading = true;
    notifyListeners();

    final response = await BackendService.instance.getAllProfiles();

    if (response.success) {
      _profiles = response.data ?? [];

      // Load shortlists if user is logged in
      final currentUser = AuthService.instance.currentUser;
      if (currentUser != null) {
        final shortlistResponse = await BackendService.instance.getShortlisted(
          currentUser.id,
        );
        if (shortlistResponse.success) {
          _shortlistedIds =
              shortlistResponse.data?.map((p) => p.id).toSet() ?? {};
        }
      }
    }

    await fetchAnalytics();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchAnalytics() async {
    final currentUser = AuthService.instance.currentUser;
    if (currentUser == null) return;

    final response = await BackendService.instance.getUserAnalytics(
      currentUser.id,
    );
    if (response.success) {
      _analytics = response.data;
      notifyListeners();
    }
  }

  Future<UserProfile?> fetchProfile(String userId) async {
    final curUser = AuthService.instance.currentUser;
    final response = await BackendService.instance.getProfile(
      userId,
      viewerId: curUser?.id,
    );

    if (response.success && response.data != null) {
      final updatedProfile = response.data!;
      final index = _profiles.indexWhere((p) => p.id == updatedProfile.id);
      if (index != -1) {
        _profiles[index] = updatedProfile;
      } else {
        _profiles.add(updatedProfile);
      }
      notifyListeners();
      return updatedProfile;
    }
    return null;
  }

  bool isShortlisted(String id) => _shortlistedIds.contains(id);

  Future<void> toggleShortlist(String id) async {
    final currentUser = AuthService.instance.currentUser;
    if (currentUser == null) return;

    final response = await BackendService.instance.toggleShortlist(
      currentUser.id,
      id,
    );
    if (response.success) {
      if (_shortlistedIds.contains(id)) {
        _shortlistedIds.remove(id);
      } else {
        _shortlistedIds.add(id);
      }
      notifyListeners();
    }
  }

  List<UserProfile> shortlistProfiles() {
    return _profiles.where((p) => _shortlistedIds.contains(p.id)).toList();
  }

  Future<List<UserProfile>> searchProfiles({
    int? minAge,
    int? maxAge,
    String? location,
    String? caste,
  }) async {
    // For now, filtering locally to keep it simple,
    // but in a real app this would be a Postgres query
    final currentUser = AuthService.instance.currentUser;
    return _profiles.where((p) {
      if (currentUser != null && p.id == currentUser.id) return false;
      if (minAge != null && p.age < minAge) return false;
      if (maxAge != null && p.age > maxAge) return false;
      if (location != null &&
          !p.location.toLowerCase().contains(location.toLowerCase())) {
        return false;
      }
      if (caste != null &&
          !(p.caste?.toLowerCase().contains(caste.toLowerCase()) ?? false)) {
        return false;
      }
      return true;
    }).toList();
  }

  Future<bool> updateProfile(UserProfile user) async {
    final response = await BackendService.instance.updateProfile(user);
    if (response.success) {
      final index = _profiles.indexWhere((p) => p.id == user.id);
      if (index != -1) {
        _profiles[index] = user;
      }
      notifyListeners();
      return true;
    }
    return false;
  }

  UserProfile? getProfileById(String id) {
    try {
      return _profiles.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> updateProfilePhoto(List<int> bytes, String filename) async {
    final response = await BackendService.instance.updateProfilePhoto(
      bytes,
      filename,
    );
    if (response.success) {
      notifyListeners();
    }
  }

  Future<bool> addAdditionalPhoto(List<int> bytes, String filename) async {
    final response = await BackendService.instance.addAdditionalPhoto(
      bytes,
      filename,
    );
    if (response.success) {
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<void> removePhoto(int index) async {
    final response = await BackendService.instance.removePhoto(index);
    if (response.success) {
      notifyListeners();
    }
  }

  Future<void> uploadHoroscope(List<int> bytes, String filename) async {
    final response = await BackendService.instance.uploadHoroscope(
      bytes,
      filename,
    );
    if (response.success) {
      notifyListeners();
    }
  }

  bool _shouldHighlightBadge = false;
  bool get shouldHighlightBadge => _shouldHighlightBadge;

  void triggerBadgeHighlight() {
    _shouldHighlightBadge = true;
    notifyListeners();
    Future.delayed(const Duration(seconds: 2), () {
      _shouldHighlightBadge = false;
      notifyListeners();
    });
  }

  void refresh() {
    notifyListeners();
  }
}
