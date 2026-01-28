import 'package:flutter/material.dart';
import '../models/user_profile_model.dart';
import '../services/profile_service.dart';

class ProfileDetailScreen extends StatefulWidget {
  final String userId;

  const ProfileDetailScreen({super.key, required this.userId});

  @override
  State<ProfileDetailScreen> createState() => _ProfileDetailScreenState();
}

class _ProfileDetailScreenState extends State<ProfileDetailScreen> {
  late UserProfile profile;
  bool isLoading = true;
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  void _loadProfile() {
    // In a real app, this would be an async fetch
    final result = ProfileService().getProfileById(widget.userId);
    if (result != null) {
      profile = result;
      isLoading = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFFD1C8),
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildQuickStats(),
                  const SizedBox(height: 24),
                  _buildSectionTitle('About Me'),
                  _buildContentCard(profile.bio),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Education & Career'),
                  _buildEducationCareerSection(),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Family Details'),
                  _buildFamilySection(),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Community'),
                  _buildCommunitySection(),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Horoscope Details'),
                  _buildHoroscopeSection(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: _buildBottomActions(),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 400,
      pinned: true,
      stretch: true,
      backgroundColor: const Color(0xFF820815),
      leading: CircleAvatar(
        backgroundColor: Colors.black.withValues(alpha: 0.3),
        child: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() => _currentPage = index);
              },
              itemCount: profile.photos.length,
              itemBuilder: (context, index) {
                return Image.network(profile.photos[index], fit: BoxFit.cover);
              },
            ),
            if (profile.photos.length > 1)
              Positioned(
                bottom: 20,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    profile.photos.length,
                    (index) => Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _currentPage == index
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                ),
              ),
            // Verified Badge
            if (profile.isVerified)
              Positioned(
                top: 60,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.verified, color: Colors.white, size: 16),
                      SizedBox(width: 4),
                      Text(
                        'Verified',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          profile.name,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF820815),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildStatChip('${profile.age} yrs'),
            _buildStatChip("${profile.height}'"),
            _buildStatChip(profile.location.split(',')[0]),
          ],
        ),
      ],
    );
  }

  Widget _buildStatChip(String label) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF820815).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF820815),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Color(0xFF820815),
        ),
      ),
    );
  }

  Widget _buildContentCard(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          height: 1.5,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildEducationCareerSection() {
    return _buildDetailList([
      {'label': 'Education', 'value': profile.education, 'icon': Icons.school},
      {'label': 'Occupation', 'value': profile.occupation, 'icon': Icons.work},
      {'label': 'Company', 'value': profile.company, 'icon': Icons.business},
      {
        'label': 'Annual Income',
        'value': profile.income,
        'icon': Icons.currency_rupee,
      },
    ]);
  }

  Widget _buildFamilySection() {
    return _buildDetailList([
      {
        'label': 'Father',
        'value': '${profile.fatherName} (${profile.fatherOccupation})',
        'icon': Icons.person,
      },
      {
        'label': 'Mother',
        'value': '${profile.motherName} (${profile.motherOccupation})',
        'icon': Icons.person_outline,
      },
      {
        'label': 'Siblings',
        'value': profile.siblings == 0 ? 'None' : '${profile.siblings}',
        'icon': Icons.group,
      },
    ]);
  }

  Widget _buildCommunitySection() {
    return _buildDetailList([
      {
        'label': 'Caste',
        'value': '${profile.caste} (${profile.subCaste})',
        'icon': Icons.people,
      },
      {'label': 'Gothra', 'value': profile.gothra, 'icon': Icons.history},
      {'label': 'Kul', 'value': profile.kul, 'icon': Icons.temple_hindu},
      {
        'label': 'Manglik',
        'value': profile.manglikStatus.name.toUpperCase(),
        'icon': Icons.star_border,
      },
    ]);
  }

  Widget _buildHoroscopeSection() {
    bool hasTemplate =
        profile.rashi != null ||
        profile.nakshatra != null ||
        profile.birthTime != null ||
        profile.birthPlace != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hasTemplate)
          _buildDetailList([
            if (profile.rashi != null)
              {
                'label': 'Rashi',
                'value': profile.rashi!,
                'icon': Icons.brightness_high,
              },
            if (profile.nakshatra != null)
              {
                'label': 'Nakshatra',
                'value': profile.nakshatra!,
                'icon': Icons.wb_sunny_outlined,
              },
            if (profile.birthTime != null)
              {
                'label': 'Time of Birth',
                'value': profile.birthTime!,
                'icon': Icons.access_time,
              },
            if (profile.birthPlace != null)
              {
                'label': 'Place of Birth',
                'value': profile.birthPlace!,
                'icon': Icons.location_on_outlined,
              },
          ]),
        if (hasTemplate && profile.horoscopeImageUrl != null)
          const SizedBox(height: 16),
        if (profile.horoscopeImageUrl != null)
          GestureDetector(
            onTap: () {
              // Future: Implement full screen image viewer
            },
            child: Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                image: DecorationImage(
                  image: NetworkImage(profile.horoscopeImageUrl!),
                  fit: BoxFit.cover,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(16),
                          bottomRight: Radius.circular(16),
                        ),
                      ),
                      child: const Center(
                        child: Text(
                          'View Horoscope Image',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        if (!hasTemplate && profile.horoscopeImageUrl == null)
          _buildContentCard('Horoscope details not provided.'),
      ],
    );
  }

  Widget _buildDetailList(List<Map<String, dynamic>> items) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: items.map((item) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  item['icon'] as IconData,
                  size: 20,
                  color: const Color(0xFF820815),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['label'] as String,
                        style: TextStyle(
                          fontSize: 12,
                          color: const Color(0xFF820815).withValues(alpha: 0.6),
                        ),
                      ),
                      Text(
                        item['value'] as String,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF820815)),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                'Shortlist',
                style: TextStyle(color: Color(0xFF820815)),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Interest sent successfully!')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF820815),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                'Send Interest',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
