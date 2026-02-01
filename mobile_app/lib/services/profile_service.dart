import 'package:flutter/foundation.dart';
import 'package:shared/shared.dart';

class ProfileService extends ChangeNotifier {
  static final ProfileService instance = ProfileService._internal();
  ProfileService._internal();
  factory ProfileService() => instance;

  List<UserProfile> _profiles = [];
  Set<String> _shortlistedIds = {};
  bool _isLoading = false;

  List<UserProfile> get profiles => _profiles;
  Set<String> get shortlistedIds => _shortlistedIds;
  bool get isLoading => _isLoading;

  /// Fetch profiles from the mock backend
  Future<void> fetchProfiles() async {
    _isLoading = true;
    notifyListeners();

    final response = await MockBackend.instance.getProfiles();
    if (response.success && response.data != null) {
      _profiles = response.data!;
    }

    final shortlistResponse = await MockBackend.instance.getShortlistedIds();
    if (shortlistResponse.success && shortlistResponse.data != null) {
      _shortlistedIds = shortlistResponse.data!;
    }

    _isLoading = false;
    notifyListeners();
  }

  bool isShortlisted(String id) => _shortlistedIds.contains(id);

  Future<void> toggleShortlist(String id) async {
    final response = await MockBackend.instance.toggleShortlist(id);
    if (response.success) {
      if (response.data == true) {
        _shortlistedIds.add(id);
      } else {
        _shortlistedIds.remove(id);
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
    final response = await MockBackend.instance.searchProfiles(
      minAge: minAge,
      maxAge: maxAge,
      location: location,
      caste: caste,
    );
    return response.data ?? [];
  }

  Future<bool> updateProfile(UserProfile user) async {
    final response = await MockBackend.instance.updateProfile(user);
    if (response.success) {
      final index = _profiles.indexWhere((p) => p.id == user.id);
      if (index != -1) {
        _profiles[index] = user;
        notifyListeners();
      }
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
}
