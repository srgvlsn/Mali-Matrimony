enum Gender { male, female, other }

enum MaritalStatus { neverMarried, divorced, widowed, awaitedDivorce }

extension MaritalStatusExtension on MaritalStatus {
  String get displayValue {
    switch (this) {
      case MaritalStatus.neverMarried:
        return 'Unmarried';
      case MaritalStatus.divorced:
        return 'Divorced';
      case MaritalStatus.widowed:
        return 'Widowed';
      case MaritalStatus.awaitedDivorce:
        return 'Awaiting Divorce';
    }
  }
}

class UserProfile {
  final String id;
  final String name;
  final String? phone;
  final String? email;
  final int age;
  final double height; // in feet or cm
  final Gender gender;
  final MaritalStatus maritalStatus;
  // Education & Career
  final String education;
  final String occupation;
  final String company;
  final String income; // Represented as range
  final String location; // City, State
  final String? hometown;
  final String? workMode;

  // Family
  final String fatherName;
  final String motherName;
  final int siblings;

  // Community
  final String religion;
  final String caste;
  final String subCaste;
  final String motherTongue;
  final List<String> languages;

  // Media
  final List<String> photos;
  final String bio;
  final String partnerPreferences;
  final String? horoscopeImageUrl;

  // Horoscope Detailed (Template)
  final String? rashi;
  final String? nakshatra;
  final String? birthTime;
  final String? birthPlace;

  // Status
  final bool isVerified;
  final bool isPremium;

  UserProfile({
    required this.id,
    required this.name,
    this.phone,
    this.email,
    required this.age,
    required this.height,
    required this.gender,
    required this.maritalStatus,
    required this.religion,
    required this.caste,
    required this.subCaste,
    required this.motherTongue,
    required this.languages,
    required this.education,
    required this.occupation,
    required this.company,
    required this.income,
    required this.location,
    this.hometown,
    this.workMode,
    required this.fatherName,
    required this.motherName,
    required this.siblings,
    required this.photos,
    required this.bio,
    this.partnerPreferences = '',
    this.horoscopeImageUrl,
    this.rashi,
    this.nakshatra,
    this.birthTime,
    this.birthPlace,
    this.isVerified = false,
    this.isPremium = false,
  });

  UserProfile copyWith({
    String? name,
    String? phone,
    String? email,
    int? age,
    double? height,
    Gender? gender,
    MaritalStatus? maritalStatus,
    String? religion,
    String? caste,
    String? subCaste,
    String? motherTongue,
    List<String>? languages,
    String? education,
    String? occupation,
    String? company,
    String? income,
    String? location,
    String? hometown,
    String? workMode,
    String? fatherName,
    String? motherName,
    int? siblings,
    List<String>? photos,
    String? bio,
    String? partnerPreferences,
    String? horoscopeImageUrl,
    String? rashi,
    String? nakshatra,
    String? birthTime,
    String? birthPlace,
    bool? isVerified,
    bool? isPremium,
  }) {
    return UserProfile(
      id: this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      age: age ?? this.age,
      height: height ?? this.height,
      gender: gender ?? this.gender,
      maritalStatus: maritalStatus ?? this.maritalStatus,
      religion: religion ?? this.religion,
      caste: caste ?? this.caste,
      subCaste: subCaste ?? this.subCaste,
      motherTongue: motherTongue ?? this.motherTongue,
      languages: languages ?? this.languages,
      education: education ?? this.education,
      occupation: occupation ?? this.occupation,
      company: company ?? this.company,
      income: income ?? this.income,
      location: location ?? this.location,
      hometown: hometown ?? this.hometown,
      workMode: workMode ?? this.workMode,
      fatherName: fatherName ?? this.fatherName,
      motherName: motherName ?? this.motherName,
      siblings: siblings ?? this.siblings,
      photos: photos ?? this.photos,
      bio: bio ?? this.bio,
      partnerPreferences: partnerPreferences ?? this.partnerPreferences,
      horoscopeImageUrl: horoscopeImageUrl ?? this.horoscopeImageUrl,
      rashi: rashi ?? this.rashi,
      nakshatra: nakshatra ?? this.nakshatra,
      birthTime: birthTime ?? this.birthTime,
      birthPlace: birthPlace ?? this.birthPlace,
      isVerified: isVerified ?? this.isVerified,
      isPremium: isPremium ?? this.isPremium,
    );
  }

  double get completionPercentage {
    final fields = [
      name,
      email,
      education,
      occupation,
      company,
      income,
      location,
      hometown,
      workMode,
      fatherName,
      motherName,
      bio,
      partnerPreferences,
      rashi,
      nakshatra,
      birthTime,
      birthPlace,
    ];

    int filledCount = fields
        .where((f) => f != null && f.toString().trim().isNotEmpty)
        .length;

    filledCount += 4; // age, height, siblings, gender (enums/nums)
    if (languages.isNotEmpty) filledCount++;

    if (photos.isNotEmpty) filledCount++;
    if (email != null && email!.isNotEmpty) filledCount++;

    return (filledCount / 24).clamp(0.0, 1.0);
  }

  /// Convert UserProfile to Map for database insertion
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'age': age,
      'height': height,
      'gender': gender.name,
      'marital_status': maritalStatus.name,
      'religion': religion,
      'caste': caste,
      'sub_caste': subCaste,
      'mother_tongue': motherTongue,
      'languages': languages,
      'education': education,
      'occupation': occupation,
      'company': company,
      'income': income,
      'location': location,
      'hometown': hometown,
      'work_mode': workMode,
      'father_name': fatherName,
      'mother_name': motherName,
      'siblings': siblings,
      'photos': photos,
      'bio': bio,
      'partner_preferences': partnerPreferences,
      'horoscope_image_url': horoscopeImageUrl,
      'rashi': rashi,
      'nakshatra': nakshatra,
      'birth_time': birthTime,
      'birth_place': birthPlace,
      'is_verified': isVerified,
      'is_premium': isPremium,
    };
  }

  /// Create UserProfile from database Map
  static UserProfile fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'] as String,
      name: map['name'] as String,
      phone: map['phone'] as String?,
      email: map['email'] as String?,
      age: map['age'] as int,
      height: (map['height'] as num).toDouble(),
      gender: Gender.values.firstWhere((e) => e.name == map['gender']),
      maritalStatus: MaritalStatus.values.firstWhere(
        (e) => e.name == map['marital_status'],
      ),
      religion: map['religion'] as String,
      caste: map['caste'] as String,
      subCaste: map['sub_caste'] as String,
      motherTongue: map['mother_tongue'] as String,
      languages: (map['languages'] as List<dynamic>?)?.cast<String>() ?? [],
      education: map['education'] as String,
      occupation: map['occupation'] as String,
      company: map['company'] as String,
      income: map['income'] as String,
      location: map['location'] as String,
      hometown: map['hometown'] as String?,
      workMode: map['work_mode'] as String?,
      fatherName: map['father_name'] as String,
      motherName: map['mother_name'] as String,
      siblings: map['siblings'] as int,
      photos: (map['photos'] as List<dynamic>?)?.cast<String>() ?? [],
      bio: map['bio'] as String,
      partnerPreferences: map['partner_preferences'] as String? ?? '',
      horoscopeImageUrl: map['horoscope_image_url'] as String?,
      rashi: map['rashi'] as String?,
      nakshatra: map['nakshatra'] as String?,
      birthTime: map['birth_time'] as String?,
      birthPlace: map['birth_place'] as String?,
      isVerified: map['is_verified'] as bool? ?? false,
      isPremium: map['is_premium'] as bool? ?? false,
    );
  }
}
