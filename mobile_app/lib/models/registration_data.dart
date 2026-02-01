import 'dart:convert';
import 'package:shared/shared.dart';

class RegistrationData {
  RegistrationData();

  String? fullName;
  String? phone;
  String? email;
  String? password;

  String? gender;
  String? height;
  String? maritalStatus;
  DateTime? dob;

  String? caste;
  String? subCaste;
  String? motherTongue;
  String? languages; // Comma-separated string from UI
  int? siblings;

  String? fatherName;
  String? motherName;

  String? education;
  String? profession;
  String? company;
  String? annualIncome;
  String? workingCity;
  String? hometown;
  String? workMode;

  String? aboutMe;
  String? partnerPreferences;

  String? profileImagePath;
  List<String>? additionalImagePaths;
  String? horoscopeImagePath;

  int lastCompletedStep = 1;

  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'phone': phone,
      'email': email,
      'password': password,
      'gender': gender,
      'height': height,
      'maritalStatus': maritalStatus,
      'dob': dob?.toIso8601String(),
      'caste': caste,
      'subCaste': subCaste,
      'motherTongue': motherTongue,
      'languages': languages,
      'siblings': siblings,
      'fatherName': fatherName,
      'motherName': motherName,
      'education': education,
      'profession': profession,
      'company': company,
      'annualIncome': annualIncome,
      'workingCity': workingCity,
      'hometown': hometown,
      'workMode': workMode,
      'aboutMe': aboutMe,
      'partnerPreferences': partnerPreferences,
      'profileImagePath': profileImagePath,
      'additionalImagePaths': additionalImagePaths,
      'horoscopeImagePath': horoscopeImagePath,
      'lastCompletedStep': lastCompletedStep,
    };
  }

  factory RegistrationData.fromMap(Map<String, dynamic> map) {
    return RegistrationData()
      ..fullName = map['fullName']
      ..phone = map['phone']
      ..email = map['email']
      ..password = map['password']
      ..gender = map['gender']
      ..height = map['height']
      ..maritalStatus = map['maritalStatus']
      ..dob = map['dob'] != null ? DateTime.parse(map['dob']) : null
      ..caste = map['caste']
      ..subCaste = map['subCaste']
      ..motherTongue = map['motherTongue']
      ..languages = map['languages']
      ..siblings = map['siblings']
      ..fatherName = map['fatherName']
      ..motherName = map['motherName']
      ..education = map['education']
      ..profession = map['profession']
      ..company = map['company']
      ..annualIncome = map['annualIncome']
      ..workingCity = map['workingCity']
      ..hometown = map['hometown']
      ..workMode = map['workMode']
      ..aboutMe = map['aboutMe']
      ..partnerPreferences = map['partnerPreferences']
      ..profileImagePath = map['profileImagePath']
      ..additionalImagePaths = (map['additionalImagePaths'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList()
      ..horoscopeImagePath = map['horoscopeImagePath']
      ..lastCompletedStep = map['lastCompletedStep'] ?? 1;
  }

  String toJson() => jsonEncode(toMap());

  static RegistrationData fromJson(String json) =>
      RegistrationData.fromMap(jsonDecode(json));

  UserProfile toUserProfile() {
    List<String> parsedLanguages = [];
    if (languages != null && languages!.isNotEmpty) {
      parsedLanguages = languages!
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }

    return UserProfile(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      name: fullName ?? 'Anonymous',
      phone: phone,
      email: email,
      age: dob != null ? DateTime.now().year - dob!.year : 25,
      height: double.tryParse(height?.replaceAll("'", ".") ?? '5.5') ?? 5.5,
      gender: gender?.toLowerCase() == 'male' ? Gender.male : Gender.female,
      maritalStatus: _parseMaritalStatus(maritalStatus),
      religion: 'Hindu',
      caste: caste ?? 'Mali',
      subCaste: subCaste ?? 'Lingayat Mali',
      motherTongue: motherTongue ?? 'Marathi',
      languages: parsedLanguages,
      education: education ?? 'N/A',
      occupation: profession ?? 'N/A',
      company: company ?? 'N/A',
      income: annualIncome ?? 'N/A',
      location: workingCity ?? 'N/A',
      hometown: hometown,
      workMode: workMode,
      fatherName: fatherName ?? 'N/A',
      motherName: motherName ?? 'N/A',
      siblings: siblings ?? 0,
      photos: profileImagePath != null ? [profileImagePath!] : [],
      bio: aboutMe ?? '',
      partnerPreferences: partnerPreferences ?? '',
      horoscopeImageUrl: horoscopeImagePath,
    );
  }

  MaritalStatus _parseMaritalStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'unmarried':
      case 'never married':
        return MaritalStatus.neverMarried;
      case 'divorced':
      case 'divorced/widowed':
        return MaritalStatus.divorced;
      case 'widowed':
        return MaritalStatus.widowed;
      case 'awaited divorce':
        return MaritalStatus.awaitedDivorce;
      default:
        return MaritalStatus.neverMarried;
    }
  }
}
