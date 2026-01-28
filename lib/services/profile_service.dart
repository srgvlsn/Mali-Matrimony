import '../models/user_profile_model.dart';

class ProfileService {
  final List<UserProfile> _mockProfiles = [
    UserProfile(
      id: 'user_123',
      name: 'Priya Sharma',
      age: 26,
      height: 5.4,
      gender: Gender.female,
      maritalStatus: MaritalStatus.neverMarried,
      religion: 'Hindu',
      caste: 'Mali',
      subCaste: 'Lingayat Mali',
      motherTongue: 'Marathi',
      gothra: 'Kashyap',
      kul: 'Adarsh',
      manglikStatus: ManglikStatus.nonManglik,
      education: 'M.Tech in Computer Science',
      occupation: 'Software Engineer',
      company: 'TCS',
      income: '12-15 LPA',
      location: 'Pune, Maharashtra',
      fatherName: 'Rajesh Sharma',
      fatherOccupation: 'Businessman',
      motherName: 'Sunita Sharma',
      motherOccupation: 'Home Maker',
      siblings: 2,
      photos: [
        'https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=1000&auto=format&fit=crop',
        'https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=1000&auto=format&fit=crop',
      ],
      bio:
          'I am a simple, down-to-earth person with a positive outlook towards life. I value family traditions and am looking for someone who is compatible and understanding.',
      rashi: 'Mesh (Aries)',
      nakshatra: 'Ashwini',
      birthTime: '10:30 AM',
      birthPlace: 'Pune',
      horoscopeImageUrl:
          'https://images.unsplash.com/photo-1532968961962-8a0cb3a2d4f5?q=80&w=1000&auto=format&fit=crop',
      isVerified: true,
      isPremium: true,
    ),
    UserProfile(
      id: 'user_456',
      name: 'Rahul Kumar',
      age: 29,
      height: 5.11,
      gender: Gender.male,
      maritalStatus: MaritalStatus.neverMarried,
      religion: 'Hindu',
      caste: 'Mali',
      subCaste: 'Lingayat Mali',
      motherTongue: 'Hindi',
      gothra: 'Vatsa',
      kul: 'Vishwakarma',
      manglikStatus: ManglikStatus.nonManglik,
      education: 'MBA in Finance',
      occupation: 'Investment Banker',
      company: 'HDFC Bank',
      income: '18-20 LPA',
      location: 'Mumbai, Maharashtra',
      fatherName: 'Vijay Kumar',
      fatherOccupation: 'Retired Government Officer',
      motherName: 'Meena Kumar',
      motherOccupation: 'Teacher',
      siblings: 1,
      photos: [
        'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=1000&auto=format&fit=crop',
        'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?q=80&w=1000&auto=format&fit=crop',
      ],
      bio:
          'Passionate about traveling and exploring new cultures. Looking for a partner who can join me in these adventures and share a meaningful life together.',
      rashi: 'Sinha (Leo)',
      nakshatra: 'Magha',
      birthTime: '02:45 PM',
      birthPlace: 'Mumbai',
      isVerified: true,
    ),
    UserProfile(
      id: 'user_789',
      name: 'Anjali Patel',
      age: 25,
      height: 5.2,
      gender: Gender.female,
      maritalStatus: MaritalStatus.neverMarried,
      religion: 'Hindu',
      caste: 'Mali',
      subCaste: 'Lingayat Mali',
      motherTongue: 'Gujarati',
      gothra: 'Bharadwaj',
      kul: 'Suryavanshi',
      manglikStatus: ManglikStatus.anshik,
      education: 'MBBS',
      occupation: 'Doctor',
      company: 'Apollo Hospital',
      income: '15-18 LPA',
      location: 'Ahmedabad, Gujarat',
      fatherName: 'Sanjay Patel',
      fatherOccupation: 'Physician',
      motherName: 'Rekha Patel',
      motherOccupation: 'Doctor',
      siblings: 0,
      photos: [
        'https://images.unsplash.com/photo-1531123897727-8f129e16fd3c?q=80&w=1000&auto=format&fit=crop',
      ],
      bio:
          'Medicine is my passion, but I also love painting and music. I believe in mutual respect and equality in a relationship.',
      rashi: 'Kanya (Virgo)',
      nakshatra: 'Hasta',
      birthTime: '07:15 AM',
      birthPlace: 'Ahmedabad',
      horoscopeImageUrl:
          'https://images.unsplash.com/photo-1502134249126-9f3755a50d78?q=80&w=1000&auto=format&fit=crop',
      isVerified: true,
    ),
  ];

  List<UserProfile> get mockProfiles => _mockProfiles;

  UserProfile? getProfileById(String id) {
    try {
      return _mockProfiles.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }
}
