import 'models/user_profile_model.dart';

class MockData {
  static final List<UserProfile> profiles = [
    UserProfile(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      name: 'Lucas Haramann',
      phone: '9119119119',
      email: null,
      age: 25,
      height: 165,
      gender: Gender.male,
      maritalStatus: MaritalStatus.neverMarried,
      religion: 'Hindu',
      caste: 'Mali',
      subCaste: 'Lingayat Mali',
      motherTongue: 'Marathi',
      gothra: 'N/A',
      kul: 'N/A',
      manglikStatus: ManglikStatus.dontKnow,
      education: 'N/A',
      occupation: 'N/A',
      company: 'N/A',
      income: 'N/A',
      location: 'N/A',
      fatherName: 'N/A',
      fatherOccupation: 'N/A',
      motherName: 'N/A',
      motherOccupation: 'N/A',
      siblings: 0,
      photos: [],
      bio: '',
      partnerPreferences: '',
      isVerified: false,
    ),
  ];
}
