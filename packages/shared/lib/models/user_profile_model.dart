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

enum ManglikStatus { manglik, nonManglik, anshik, dontKnow }

class UserProfile {
  final String id;
  final String name;
  final String? phone;
  final String? email;
  final int age;
  final double height; // in feet or cm
  final Gender gender;
  final MaritalStatus maritalStatus;
  final String religion;
  final String caste;
  final String subCaste;
  final String motherTongue;

  // Community / Religious
  final String gothra;
  final String kul;
  final ManglikStatus manglikStatus;

  // Education & Career
  final String education;
  final String occupation;
  final String company;
  final String income; // Represented as range
  final String location; // City, State

  // Family
  final String fatherName;
  final String fatherOccupation;
  final String motherName;
  final String motherOccupation;
  final int siblings;

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
    required this.gothra,
    required this.kul,
    required this.manglikStatus,
    required this.education,
    required this.occupation,
    required this.company,
    required this.income,
    required this.location,
    required this.fatherName,
    required this.fatherOccupation,
    required this.motherName,
    required this.motherOccupation,
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
    String? gothra,
    String? kul,
    ManglikStatus? manglikStatus,
    String? education,
    String? occupation,
    String? company,
    String? income,
    String? location,
    String? fatherName,
    String? fatherOccupation,
    String? motherName,
    String? motherOccupation,
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
      gothra: gothra ?? this.gothra,
      kul: kul ?? this.kul,
      manglikStatus: manglikStatus ?? this.manglikStatus,
      education: education ?? this.education,
      occupation: occupation ?? this.occupation,
      company: company ?? this.company,
      income: income ?? this.income,
      location: location ?? this.location,
      fatherName: fatherName ?? this.fatherName,
      fatherOccupation: fatherOccupation ?? this.fatherOccupation,
      motherName: motherName ?? this.motherName,
      motherOccupation: motherOccupation ?? this.motherOccupation,
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
      fatherName,
      fatherOccupation,
      motherName,
      motherOccupation,
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

    if (photos.isNotEmpty) filledCount++;
    if (email != null && email!.isNotEmpty) filledCount++;

    return (filledCount / 22).clamp(0.0, 1.0);
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
      'maritalStatus': maritalStatus.name,
      'religion': religion,
      'caste': caste,
      'subCaste': subCaste,
      'motherTongue': motherTongue,
      'gothra': gothra,
      'kul': kul,
      'manglikStatus': manglikStatus.name,
      'education': education,
      'occupation': occupation,
      'company': company,
      'income': income,
      'location': location,
      'fatherName': fatherName,
      'fatherOccupation': fatherOccupation,
      'motherName': motherName,
      'motherOccupation': motherOccupation,
      'siblings': siblings,
      'photos': photos,
      'bio': bio,
      'partnerPreferences': partnerPreferences,
      'horoscopeImageUrl': horoscopeImageUrl,
      'rashi': rashi,
      'nakshatra': nakshatra,
      'birthTime': birthTime,
      'birthPlace': birthPlace,
      'isVerified': isVerified,
      'isPremium': isPremium,
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
      gothra: map['gothra'] as String,
      kul: map['kul'] as String,
      manglikStatus: ManglikStatus.values.firstWhere(
        (e) => e.name == map['manglik_status'],
      ),
      education: map['education'] as String,
      occupation: map['occupation'] as String,
      company: map['company'] as String,
      income: map['income'] as String,
      location: map['location'] as String,
      fatherName: map['father_name'] as String,
      fatherOccupation: map['father_occupation'] as String,
      motherName: map['mother_name'] as String,
      motherOccupation: map['mother_occupation'] as String,
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
