import 'package:flutter/foundation.dart';
import 'package:shared/shared.dart';

class ProfileService extends ChangeNotifier {
  static final ProfileService instance = ProfileService._internal();
  ProfileService._internal();
  factory ProfileService() => instance;

  final Set<String> _shortlistedIds = {};

  final List<UserProfile> _mockProfiles = MockData.profiles;

  List<UserProfile> get mockProfiles => _mockProfiles;
  Set<String> get shortlistedIds => _shortlistedIds;

  bool isShortlisted(String id) => _shortlistedIds.contains(id);

  void toggleShortlist(String id) {
    if (_shortlistedIds.contains(id)) {
      _shortlistedIds.remove(id);
    } else {
      _shortlistedIds.add(id);
    }
    notifyListeners();
  }

  List<UserProfile> shortlistProfiles() {
    return _mockProfiles.where((p) => _shortlistedIds.contains(p.id)).toList();
  }

  List<UserProfile> searchProfiles({
    int? minAge,
    int? maxAge,
    String? location,
    String? caste,
  }) {
    return _mockProfiles.where((p) {
      if (minAge != null && p.age < minAge) return false;
      if (maxAge != null && p.age > maxAge) return false;
      if (location != null &&
          !p.location.toLowerCase().contains(location.toLowerCase())) {
        return false;
      }
      if (caste != null &&
          !p.caste.toLowerCase().contains(caste.toLowerCase())) {
        return false;
      }
      return true;
    }).toList();
  }

  UserProfile? getProfileById(String id) {
    try {
      return _mockProfiles.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }
}
