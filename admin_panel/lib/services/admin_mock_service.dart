import '../models/user_profile_model.dart';

class AdminMockService {
  static final AdminMockService instance = AdminMockService._internal();

  AdminMockService._internal();

  factory AdminMockService() => instance;

  List<UserProfile> _allUsers = [];

  void init() {
    _allUsers = [
      UserProfile(
        id: 'user_123',
        name: 'Priya Sharma',
        age: 26,
        height: 5.4,
        gender: Gender.female,
        maritalStatus: MaritalStatus.neverMarried,
        religion: 'Hindu',
        caste: 'Lingayat',
        subCaste: 'Pancham',
        motherTongue: 'Marathi',
        gothra: 'Kashyap',
        kul: 'Khandoba',
        manglikStatus: ManglikStatus.nonManglik,
        education: 'B.Tech CS',
        occupation: 'Software Engineer',
        company: 'Infosys',
        income: '8-10 LPA',
        location: 'Pune, MH',
        fatherName: 'Ramesh Sharma',
        fatherOccupation: 'Business',
        motherName: 'Sunita Sharma',
        motherOccupation: 'Homemaker',
        siblings: 1,
        photos: ['https://randomuser.me/api/portraits/women/1.jpg'],
        bio: 'Simple and down to earth.',
        isVerified: true,
      ),
      UserProfile(
        id: 'user_456',
        name: 'Rahul Kumar',
        age: 28,
        height: 5.9,
        gender: Gender.male,
        maritalStatus: MaritalStatus.neverMarried,
        religion: 'Hindu',
        caste: 'Lingayat',
        subCaste: 'Dixit',
        motherTongue: 'Kannada',
        gothra: 'Vasishta',
        kul: 'Renuka',
        manglikStatus: ManglikStatus.manglik,
        education: 'MBA',
        occupation: 'Manager',
        company: 'Tata Motors',
        income: '12-15 LPA',
        location: 'Belgaum, KA',
        fatherName: 'Suresh Kumar',
        fatherOccupation: 'Retired',
        motherName: 'Geeta Kumar',
        motherOccupation: 'Teacher',
        siblings: 2,
        photos: ['https://randomuser.me/api/portraits/men/1.jpg'],
        bio: 'Ambitious and family oriented.',
        isVerified: false, // Pending verification
      ),
      UserProfile(
        id: 'user_789',
        name: 'Anjali Patel',
        age: 25,
        height: 5.3,
        gender: Gender.female,
        maritalStatus: MaritalStatus.neverMarried,
        religion: 'Hindu',
        caste: 'Lingayat',
        subCaste: 'Banajig',
        motherTongue: 'Hindi',
        gothra: 'Bharadwaj',
        kul: 'Tuljabhavani',
        manglikStatus: ManglikStatus.dontKnow,
        education: 'M.Com',
        occupation: 'Accountant',
        company: 'Local Firm',
        income: '4-6 LPA',
        location: 'Solapur, MH',
        fatherName: 'Deepak Patel',
        fatherOccupation: 'Farmer',
        motherName: 'Meena Patel',
        motherOccupation: 'Homemaker',
        siblings: 3,
        photos: ['https://randomuser.me/api/portraits/women/2.jpg'],
        bio: 'Looking for a supportive partner.',
        isVerified: false,
      ),
    ];
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
}
