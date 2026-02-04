import 'package:flutter/material.dart';
import 'package:shared/shared.dart';
import '../services/profile_service.dart';
import '../services/interest_service.dart';
import '../services/chat_service.dart';
import 'chat_detail_screen.dart';
import 'package:provider/provider.dart';
import '../widgets/profile_widgets.dart';

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
  bool isShortlisted = false;
  bool _isSendingInterest = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    // Initial load from local cache if available
    final result = ProfileService().getProfileById(widget.userId);
    if (result != null) {
      setState(() {
        profile = result;
        isLoading = false;
        isShortlisted = ProfileService.instance.isShortlisted(widget.userId);
      });
    }

    // Refresh from backend to trigger "Profile Viewed" notification
    final updated = await ProfileService().fetchProfile(widget.userId);
    if (updated != null && mounted) {
      setState(() {
        profile = updated;
        isLoading = false;
        isShortlisted = ProfileService.instance.isShortlisted(widget.userId);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                  const SectionTitle(title: 'About Me'),
                  ContentCard(text: profile.bio),
                  const SizedBox(height: 24),
                  const SectionTitle(title: 'Personal Details'),
                  _buildPersonalDetailsSection(),
                  const SizedBox(height: 24),
                  const SectionTitle(title: 'Education & Career'),
                  _buildEducationCareerSection(),
                  const SizedBox(height: 24),
                  const SectionTitle(title: 'Family Details'),
                  _buildFamilySection(),
                  const SizedBox(height: 24),
                  const SectionTitle(title: 'Community'),
                  _buildCommunitySection(),
                  const SizedBox(height: 24),
                  const SectionTitle(title: 'Horoscope'),
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
      backgroundColor: Theme.of(context).colorScheme.primary,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CircleAvatar(
          backgroundColor: Colors.black.withValues(alpha: 0.3),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
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
                return Image.network(
                  ApiService.instance.resolveUrl(profile.photos[index]),
                  fit: BoxFit.cover,
                );
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
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            StatChip(label: '${profile.age} yrs'),
            StatChip(label: '${profile.height.toInt()} cm'),
            StatChip(label: profile.location.split(',')[0]),
          ],
        ),
      ],
    );
  }

  Widget _buildEducationCareerSection() {
    return DetailListCard(
      items: [
        {
          'label': 'Education',
          'value': profile.education,
          'icon': Icons.school,
        },
        {
          'label': 'Occupation',
          'value': profile.occupation,
          'icon': Icons.work,
        },
        {'label': 'Company', 'value': profile.company, 'icon': Icons.business},
        {
          'label': 'Annual Income',
          'value': profile.income,
          'icon': Icons.currency_rupee,
        },
        if (profile.workMode != null && profile.workMode!.isNotEmpty)
          {
            'label': 'Work Mode',
            'value': profile.workMode!,
            'icon': Icons.laptop,
          },
      ],
    );
  }

  Widget _buildFamilySection() {
    return DetailListCard(
      items: [
        {'label': 'Father', 'value': profile.fatherName, 'icon': Icons.person},
        {
          'label': 'Mother',
          'value': profile.motherName,
          'icon': Icons.person_outline,
        },
        {
          'label': 'Siblings',
          'value': profile.siblings == 0 ? 'None' : '${profile.siblings}',
          'icon': Icons.group,
        },
      ],
    );
  }

  Widget _buildPersonalDetailsSection() {
    return DetailListCard(
      items: [
        {
          'label': 'Date of Birth',
          'value': profile.dob != null
              ? DateFormatter.formatShortDate(profile.dob)
              : 'N/A',
          'icon': Icons.cake,
        },
        {
          'label': 'Gender',
          'value': profile.gender.name.toUpperCase(),
          'icon': Icons.person,
        },
        {
          'label': 'Marital Status',
          'value': profile.maritalStatus.displayValue,
          'icon': Icons.favorite,
        },
      ],
    );
  }

  Widget _buildCommunitySection() {
    return DetailListCard(
      items: [
        {
          'label': 'Caste',
          'value': profile.caste ?? 'Not specified',
          'icon': Icons.people,
        },
        if (profile.subCaste != null && profile.subCaste!.isNotEmpty)
          {
            'label': 'Sub-Caste',
            'value': profile.subCaste!,
            'icon': Icons.people_outline,
          },
        {
          'label': 'Mother Tongue',
          'value': profile.motherTongue,
          'icon': Icons.language,
        },
        if (profile.languages.isNotEmpty)
          {
            'label': 'Languages',
            'value': profile.languages.join(', '),
            'icon': Icons.translate,
          },
        if (profile.hometown != null && profile.hometown!.isNotEmpty)
          {'label': 'Hometown', 'value': profile.hometown!, 'icon': Icons.home},
      ],
    );
  }

  Widget _buildHoroscopeSection() {
    if (profile.horoscopeImageUrl == null) {
      return const ContentCard(text: 'Horoscope not uploaded.');
    }

    return GestureDetector(
      onTap: () => _showFullScreenImage(context, profile.horoscopeImageUrl!),
      child: Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          image: DecorationImage(
            image: NetworkImage(
              ApiService.instance.resolveUrl(profile.horoscopeImageUrl!),
            ),
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
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
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
    );
  }

  void _showFullScreenImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog.fullscreen(
        backgroundColor: Colors.black,
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: Image.network(
                  ApiService.instance.resolveUrl(imageUrl),
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    );
                  },
                ),
              ),
            ),
            Positioned(
              top: 40,
              right: 20,
              child: CircleAvatar(
                backgroundColor: Colors.black54,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomActions() {
    return Consumer<InterestService>(
      builder: (context, interestService, child) {
        final interestStatus = interestService.getStatusWithUser(widget.userId);
        final bool hasSentInterest = interestStatus != null;

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
                  onPressed: () {
                    ProfileService.instance.toggleShortlist(widget.userId);
                    setState(() {
                      isShortlisted = ProfileService.instance.isShortlisted(
                        widget.userId,
                      );
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          isShortlisted
                              ? 'Added to shortlist'
                              : 'Removed from shortlist',
                        ),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    backgroundColor: isShortlisted
                        ? Theme.of(context).colorScheme.primary
                        : Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    isShortlisted ? 'Shortlisted' : 'Shortlist',
                    style: TextStyle(
                      color: isShortlisted
                          ? Colors.white
                          : Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: interestStatus == InterestStatus.accepted
                      ? () {
                          final conversation = ChatService.instance
                              .startConversation(
                                widget.userId,
                                profile.name,
                                profile.photos.isNotEmpty
                                    ? profile.photos[0]
                                    : 'https://via.placeholder.com/150',
                              );
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  ChatDetailScreen(conversation: conversation),
                            ),
                          );
                        }
                      : hasSentInterest
                      ? null
                      : () async {
                          setState(() => _isSendingInterest = true);
                          final success = await interestService.sendInterest(
                            widget.userId,
                          );
                          if (!context.mounted) return;
                          setState(() => _isSendingInterest = false);
                          if (success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Interest sent successfully!'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Failed to send interest'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        hasSentInterest &&
                            interestStatus != InterestStatus.accepted
                        ? Colors.grey
                        : Theme.of(context).colorScheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: _isSendingInterest
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (interestStatus == InterestStatus.accepted)
                              const Padding(
                                padding: EdgeInsets.only(right: 8.0),
                                child: Icon(
                                  Icons.chat_bubble_outline,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            Text(
                              interestStatus == InterestStatus.accepted
                                  ? 'Send Message'
                                  : hasSentInterest
                                  ? 'Interest Sent'
                                  : 'Send Interest',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
