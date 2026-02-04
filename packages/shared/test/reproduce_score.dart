import 'package:shared/models/user_profile_model.dart';

void main() {
  final profile = UserProfile(
    id: 'test',
    name: 'Priya Sharma',
    phone: '9000000010',
    email: 'priya.sharma@example.com',
    age: 25,
    height: 5.4,
    gender: Gender.female,
    maritalStatus: MaritalStatus.neverMarried,
    education: 'MSc',
    occupation: 'Government Employee',
    company: 'N/A',
    income: '8-12 LPA',
    location: 'Pune',
    hometown: 'Chennai',
    workMode: null,
    fatherName: 'N/A',
    motherName: 'N/A',
    siblings: 0,
    photos: ['a', 'b'],
    bio: "Hi, I'm Priya...",
    caste: 'Mali',
    subCaste: '',
    motherTongue: 'Marathi',
    partnerPreferences: '',
    horoscopeImageUrl: null,
    languages: ['English', 'Marathi'],
  );

  print('Profile Strength: ${profile.completionPercentage}');
  print('Percentage: ${(profile.completionPercentage * 100).toInt()}%');

  // Debug Breakdown
  print('\nBreakdown:');
  int score = 0;

  // String fields to check
  final stringFields = [
    profile.name,
    profile.phone,
    profile.email,
    profile.education,
    profile.occupation,
    profile.company,
    profile.income,
    profile.location,
    profile.hometown,
    profile.workMode,
    profile.fatherName,
    profile.motherName,
    profile.caste,
    profile.subCaste,
    profile.motherTongue,
    profile.bio,
    profile.partnerPreferences,
    profile.horoscopeImageUrl,
  ];

  for (var i = 0; i < stringFields.length; i++) {
    final field = stringFields[i];
    if (field != null && field.trim().isNotEmpty) {
      print('Field $i: Present');
      score++;
    } else {
      print('Field $i: MISSING');
    }
  }
  print("String Score: $score");
}
