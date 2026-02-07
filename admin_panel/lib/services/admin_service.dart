import 'package:shared/shared.dart';

class AdminService {
  static final AdminService instance = AdminService._internal();
  AdminService._internal();

  /// Retrieve full user list from PostgreSQL
  Future<List<UserProfile>> getUsers() async {
    // Admin needs to see even blocked users
    final response = await BackendService.instance.getAllProfiles(
      includeInactive: true,
    );
    return response.data ?? [];
  }

  /// Update a specific user's profile in PostgreSQL
  Future<void> updateUser(UserProfile user) async {
    await BackendService.instance.updateProfile(user);
  }

  /// Delete a user by ID
  Future<void> deleteUser(String userId) async {
    await BackendService.instance.deleteProfile(userId);
  }

  /// Add a new user
  void addUser(UserProfile user) {
    BackendService.instance.registerUser(user);
  }

  /// Get users pending verification from PostgreSQL
  Future<List<UserProfile>> getPendingUsers() async {
    final response = await BackendService.instance.getAllProfiles();
    return (response.data ?? []).where((u) => !u.isVerified).toList();
  }

  /// Verify a user in PostgreSQL
  Future<void> verifyUser(String userId) async {
    final response = await BackendService.instance.getAllProfiles();
    final profiles = response.data ?? [];
    final index = profiles.indexWhere((u) => u.id == userId);
    if (index != -1) {
      final updated = profiles[index].copyWith(isVerified: true);
      await BackendService.instance.updateProfile(updated);
    }
  }

  /// Reject a user (deletes profile)
  Future<void> rejectUser(String userId) async {
    await BackendService.instance.deleteProfile(userId);
  }

  /// Block a user
  Future<void> blockUser(String userId) async {
    final response = await BackendService.instance.getProfile(userId);
    if (response.success && response.data != null) {
      final updated = response.data!.copyWith(isActive: false);
      await BackendService.instance.updateProfile(updated);
    }
  }

  /// Get Analytics data from backend
  Future<Map<String, dynamic>> getAnalyticsData() async {
    final response = await BackendService.instance.getAnalytics();
    if (response.success && response.data != null) {
      return response.data!;
    }

    // Return zeros on error
    return {
      'total_users': 0,
      'verified_users': 0,
      'premium_users': 0,
      'pending_verification': 0,
      'recent_registrations': 0,
      'male_users': 0,
      'female_users': 0,
    };
  }
}
