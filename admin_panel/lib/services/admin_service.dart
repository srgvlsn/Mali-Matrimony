import 'package:shared/shared.dart';

class AdminService {
  static final AdminService instance = AdminService._internal();
  AdminService._internal();

  /// Retrieve full user list from PostgreSQL
  Future<List<UserProfile>> getUsers() async {
    final response = await BackendService.instance.getAllProfiles();
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

  /// Reject a user
  void rejectUser(String userId) {
    // Implement logic if needed
  }

  // Get Analytics data (Mock for chart display)
  Map<String, dynamic> getAnalyticsData() {
    return {'totalUsers': 0, 'activeUsers': 0, 'premiumUsers': 0};
  }
}
