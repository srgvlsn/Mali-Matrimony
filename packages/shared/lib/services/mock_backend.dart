import 'dart:async';
import '../models/user_profile_model.dart';
import '../models/interest_model.dart';
import '../mock_data.dart';
import '../utils/api_response.dart';

/// A centralized Mock Backend that simulates a real API/Database.
/// It maintains local state and providing asynchronous methods with latency.
class MockBackend {
  static final MockBackend instance = MockBackend._internal();

  MockBackend._internal() {
    // Initialize with mock data
    _profiles = List.from(MockData.profiles);
    _initInterests();
  }

  // Simulated Database State
  late List<UserProfile> _profiles;
  final Set<String> _shortlistedIds = {};
  final List<InterestModel> _interests = [];
  String? _currentUserId;

  String? get currentUserId => _currentUserId;
  UserProfile? get currentUser => _currentUserId != null
      ? _profiles.firstWhere((p) => p.id == _currentUserId)
      : null;

  // Latency simulation (default 1 second)
  final Duration _delay = const Duration(seconds: 1);

  void _initInterests() {
    _interests.clear();
    _interests.addAll([
      InterestModel(
        id: 'int_1',
        senderId: 'user_123',
        receiverId: 'user_456',
        status: InterestStatus.pending,
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
      ),
      InterestModel(
        id: 'int_2',
        senderId: 'user_102',
        receiverId: 'user_456',
        status: InterestStatus.accepted,
        timestamp: DateTime.now().subtract(const Duration(days: 2)),
      ),
      InterestModel(
        id: 'int_3',
        senderId: 'user_456',
        receiverId: 'user_789',
        status: InterestStatus.pending,
        timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      ),
    ]);
  }

  // --- Auth API ---

  Future<ApiResponse<UserProfile>> login(
    String emailOrPhone,
    String password,
  ) async {
    await Future.delayed(_delay);
    if (emailOrPhone.isNotEmpty && password.isNotEmpty) {
      // Find user by email or phone (simulated)
      try {
        final user = _profiles.firstWhere(
          (p) =>
              (p.name.toLowerCase().contains(emailOrPhone.toLowerCase()) ||
              p.phone == emailOrPhone ||
              p.id == emailOrPhone),
        );
        _currentUserId = user.id;
        _initInterests();
        return ApiResponse.success(user, message: 'Login successful');
      } catch (e) {
        return ApiResponse.error('Invalid credentials');
      }
    }
    return ApiResponse.error('Invalid credentials');
  }

  Future<ApiResponse<UserProfile>> registerUser(UserProfile user) async {
    await Future.delayed(_delay);
    // Check if user already exists
    final index = _profiles.indexWhere((p) => p.id == user.id);
    if (index != -1) {
      _profiles[index] = user;
    } else {
      _profiles.add(user);
    }
    _currentUserId = user.id;
    return ApiResponse.success(user, message: 'Registration successful');
  }

  Future<ApiResponse<UserProfile>> updateProfile(UserProfile user) async {
    await Future.delayed(_delay);
    final index = _profiles.indexWhere((p) => p.id == user.id);
    if (index != -1) {
      _profiles[index] = user;
      return ApiResponse.success(user, message: 'Profile updated');
    }
    return ApiResponse.error('Profile not found');
  }

  Future<ApiResponse<void>> logout() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _currentUserId = null;
    return ApiResponse.success(null, message: 'Logged out');
  }

  // --- Profile API ---

  Future<ApiResponse<List<UserProfile>>> getProfiles() async {
    await Future.delayed(_delay);
    return ApiResponse.success(_profiles);
  }

  Future<ApiResponse<UserProfile>> getProfileById(String id) async {
    await Future.delayed(_delay);
    try {
      final profile = _profiles.firstWhere((p) => p.id == id);
      return ApiResponse.success(profile);
    } catch (e) {
      return ApiResponse.error('Profile not found');
    }
  }

  // --- Interactions API ---

  Future<ApiResponse<bool>> toggleShortlist(String profileId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (_shortlistedIds.contains(profileId)) {
      _shortlistedIds.remove(profileId);
      return ApiResponse.success(false, message: 'Removed from shortlist');
    } else {
      _shortlistedIds.add(profileId);
      return ApiResponse.success(true, message: 'Added to shortlist');
    }
  }

  Future<ApiResponse<Set<String>>> getShortlistedIds() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return ApiResponse.success(Set.from(_shortlistedIds));
  }

  // --- Search API ---

  Future<ApiResponse<List<UserProfile>>> searchProfiles({
    int? minAge,
    int? maxAge,
    String? location,
    String? caste,
  }) async {
    await Future.delayed(_delay);
    final results = _profiles.where((p) {
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
    return ApiResponse.success(results);
  }

  // --- Interests API ---

  Future<ApiResponse<List<InterestModel>>> getInterests() async {
    await Future.delayed(_delay);
    return ApiResponse.success(List.from(_interests));
  }

  Future<ApiResponse<InterestModel>> sendInterest(String receiverId) async {
    await Future.delayed(_delay);
    if (_currentUserId == null) return ApiResponse.error('Not logged in');

    final interest = InterestModel(
      id: DateTime.now().toIso8601String(),
      senderId: _currentUserId!,
      receiverId: receiverId,
      timestamp: DateTime.now(),
    );
    _interests.add(interest);
    return ApiResponse.success(interest);
  }

  Future<ApiResponse<void>> updateInterestStatus(
    String id,
    InterestStatus status,
  ) async {
    await Future.delayed(_delay);
    final index = _interests.indexWhere((i) => i.id == id);
    if (index != -1) {
      _interests[index] = _interests[index].copyWith(status: status);
      return ApiResponse.success(null);
    }
    return ApiResponse.error('Interest not found');
  }
}
