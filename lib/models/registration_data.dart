import 'dart:convert';

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

  String? education;
  String? profession;
  String? annualIncome;
  String? workingCity;
  String? workMode;

  String? aboutMe;
  String? partnerPreferences;

  String? profileImagePath;
  List<String>? additionalImagePaths;

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
      'education': education,
      'profession': profession,
      'annualIncome': annualIncome,
      'workingCity': workingCity,
      'workMode': workMode,
      'aboutMe': aboutMe,
      'partnerPreferences': partnerPreferences,
      'profileImagePath': profileImagePath,
      'additionalImagePaths': additionalImagePaths,
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
      ..education = map['education']
      ..profession = map['profession']
      ..annualIncome = map['annualIncome']
      ..workingCity = map['workingCity']
      ..workMode = map['workMode']
      ..aboutMe = map['aboutMe']
      ..partnerPreferences = map['partnerPreferences']
      ..profileImagePath = map['profileImagePath']
      ..additionalImagePaths = (map['additionalImagePaths'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList()
      ..lastCompletedStep = map['lastCompletedStep'] ?? 1;
  }

  String toJson() => jsonEncode(toMap());

  static RegistrationData fromJson(String json) =>
      RegistrationData.fromMap(jsonDecode(json));
}
