import 'package:shared/shared.dart';

class AdminMockService {
  static final AdminMockService instance = AdminMockService._internal();

  AdminMockService._internal();

  factory AdminMockService() => instance;

  List<UserProfile> _allUsers = [];

  void init() {
    _allUsers = List.from(MockData.profiles);
  }

  // Stats
  int get totalUsers => _allUsers.length;
  int get pendingVerifications => _allUsers.where((u) => !u.isVerified).length;
  int get verifiedUsers => _allUsers.where((u) => u.isVerified).length;
  List<UserProfile> get pendingUsers =>
      _allUsers.where((u) => !u.isVerified).toList();
  List<UserProfile> get allUsers => _allUsers;

  // Actions
  void verifyUser(String userId) {
    final index = _allUsers.indexWhere((u) => u.id == userId);
    if (index != -1) {
      final old = _allUsers[index];
      _allUsers[index] = UserProfile(
        id: old.id,
        name: old.name,
        age: old.age,
        height: old.height,
        gender: old.gender,
        maritalStatus: old.maritalStatus,
        religion: old.religion,
        caste: old.caste,
        subCaste: old.subCaste,
        motherTongue: old.motherTongue,
        gothra: old.gothra,
        kul: old.kul,
        manglikStatus: old.manglikStatus,
        education: old.education,
        occupation: old.occupation,
        company: old.company,
        income: old.income,
        location: old.location,
        fatherName: old.fatherName,
        fatherOccupation: old.fatherOccupation,
        motherName: old.motherName,
        motherOccupation: old.motherOccupation,
        siblings: old.siblings,
        photos: old.photos,
        bio: old.bio,
        isVerified: true,
        isPremium: old.isPremium,
      );
    }
  }

  void rejectUser(String userId) {
    // Keep unverified
  }

  void updateUser(UserProfile updatedUser) {
    final index = _allUsers.indexWhere((u) => u.id == updatedUser.id);
    if (index != -1) {
      _allUsers[index] = updatedUser;
    }
  }
}
