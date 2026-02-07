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
  final DateTime? dob;
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
  final String? caste;
  final String? subCaste;
  final String motherTongue;
  final List<String> languages;

  // Media
  final List<String> photos;
  final String bio;
  final String partnerPreferences;
  final String? horoscopeImageUrl;

  // Status
  final bool isVerified;
  final bool isPremium;
  final bool isHidden;
  final bool showPhone;
  final bool showEmail;
  final DateTime? createdAt;
  final DateTime? premiumExpiryDate;
  final bool isActive;

  UserProfile({
    required this.id,
    required this.name,
    this.phone,
    this.email,
    required this.age,
    required this.height,
    required this.gender,
    required this.maritalStatus,
    this.dob,
    this.caste,
    this.subCaste,
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
    this.isVerified = false,
    this.isPremium = false,
    this.isHidden = false,
    this.showPhone = true,
    this.showEmail = true,
    this.createdAt,
    this.premiumExpiryDate,
    this.isActive = true,
  });

  UserProfile copyWith({
    String? name,
    String? phone,
    String? email,
    int? age,
    double? height,
    Gender? gender,
    MaritalStatus? maritalStatus,
    DateTime? dob,
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
    bool? isVerified,
    bool? isPremium,
    bool? isHidden,
    bool? showPhone,
    bool? showEmail,
    DateTime? createdAt,
    DateTime? premiumExpiryDate,
    bool? isActive,
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
      dob: dob ?? this.dob,
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
      isVerified: isVerified ?? this.isVerified,
      isPremium: isPremium ?? this.isPremium,
      isHidden: isHidden ?? this.isHidden,
      showPhone: showPhone ?? this.showPhone,
      showEmail: showEmail ?? this.showEmail,
      createdAt: createdAt ?? this.createdAt,
      premiumExpiryDate: premiumExpiryDate ?? this.premiumExpiryDate,
      isActive: isActive ?? this.isActive,
    );
  }

  double get completionPercentage {
    int score = 0;
    const totalFields = 25;

    // String fields to check
    final stringFields = [
      name,
      phone,
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
      caste,
      subCaste,
      motherTongue,
      bio,
      partnerPreferences,
      horoscopeImageUrl,
    ];

    for (var field in stringFields) {
      if (field != null && field.trim().isNotEmpty) {
        score++;
      }
    }

    // Number/Enum/List fields
    if (age > 0) score++;
    if (height > 0) score++;
    if (siblings >= 0) score++; // Valid even if 0
    if (languages.isNotEmpty) score++;
    if (photos.isNotEmpty) score++;

    // Base core fields (gender, maritalStatus) are always there
    score += 2;

    return (score / totalFields).clamp(0.0, 1.0);
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
      'dob': dob?.toIso8601String(),
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
      'is_verified': isVerified,
      'is_premium': isPremium,
      'is_hidden': isHidden,
      'show_phone': showPhone,
      'show_email': showEmail,
      'created_at': createdAt?.toIso8601String(),
      'premium_expiry_date': premiumExpiryDate?.toIso8601String(),
      'is_active': isActive,
    };
  }

  /// Create UserProfile from database Map
  static UserProfile fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id:
          map['id'] as String? ??
          'unk_${DateTime.now().millisecondsSinceEpoch}',
      name: map['name'] as String? ?? 'Anonymous',
      phone: map['phone'] as String?,
      email: map['email'] as String?,
      age: map['age'] as int? ?? 25,
      height: (map['height'] as num?)?.toDouble() ?? 165.0,
      gender: Gender.values.firstWhere(
        (e) =>
            e.name.toLowerCase() == (map['gender'] as String?)?.toLowerCase(),
        orElse: () => Gender.male,
      ),
      maritalStatus: MaritalStatus.values.firstWhere(
        (e) =>
            e.name.toLowerCase() ==
            (map['marital_status'] as String?)?.toLowerCase(),
        orElse: () => MaritalStatus.neverMarried,
      ),
      dob: map['dob'] != null ? DateTime.tryParse(map['dob'] as String) : null,
      caste: map['caste'] as String?,
      subCaste: map['sub_caste'] as String?,
      motherTongue: map['mother_tongue'] as String? ?? 'Marathi',
      languages: (map['languages'] as List<dynamic>?)?.cast<String>() ?? [],
      education: map['education'] as String? ?? 'N/A',
      occupation: map['occupation'] as String? ?? 'N/A',
      company: map['company'] as String? ?? 'N/A',
      income: map['income'] as String? ?? 'N/A',
      location: map['location'] as String? ?? 'N/A',
      hometown: map['hometown'] as String?,
      workMode: map['work_mode'] as String?,
      fatherName: map['father_name'] as String? ?? 'N/A',
      motherName: map['mother_name'] as String? ?? 'N/A',
      siblings: map['siblings'] as int? ?? 0,
      photos: (map['photos'] as List<dynamic>?)?.cast<String>() ?? [],
      bio: map['bio'] as String? ?? '',
      partnerPreferences: map['partner_preferences'] as String? ?? '',
      horoscopeImageUrl: map['horoscope_image_url'] as String?,
      isVerified: map['is_verified'] as bool? ?? false,
      isPremium: map['is_premium'] as bool? ?? false,
      isHidden: map['is_hidden'] as bool? ?? false,
      showPhone: map['show_phone'] as bool? ?? true,
      showEmail: map['show_email'] as bool? ?? true,
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'] as String)
          : null,
      premiumExpiryDate: map['premium_expiry_date'] != null
          ? DateTime.tryParse(map['premium_expiry_date'] as String)
          : null,
      isActive: map['is_active'] as bool? ?? true,
    );
  }
}
