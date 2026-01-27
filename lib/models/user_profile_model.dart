enum Gender { male, female, other }

enum MaritalStatus { neverMarried, divorced, widowed, awaitedDivorce }

enum ManglikStatus { manglik, nonManglik, anshik, dontKnow }

class UserProfile {
  final String id;
  final String name;
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

  // Status
  final bool isVerified;
  final bool isPremium;

  UserProfile({
    required this.id,
    required this.name,
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
    this.isVerified = false,
    this.isPremium = false,
  });
}
