import 'package:flutter/material.dart';
import '../models/user_profile_model.dart';
import '../services/profile_service.dart';
import 'profile_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final ProfileService _profileService = ProfileService();
  late List<UserProfile> _allProfiles;
  List<UserProfile> _filteredProfiles = [];

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _allProfiles = _profileService.mockProfiles;
    _filteredProfiles = []; // Initially empty until user starts typing
  }

  void _filterProfiles(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredProfiles = [];
        return;
      }
      _filteredProfiles = _profileService.searchProfiles(location: query);
      // If location search yields nothing, try name/caste for a better UX
      if (_filteredProfiles.isEmpty) {
        _filteredProfiles = _allProfiles
            .where(
              (p) =>
                  p.name.toLowerCase().contains(query.toLowerCase()) ||
                  p.caste.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFD1C8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFD1C8),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF820815)),
          onPressed: () => Navigator.pop(context),
        ),
        title: TextField(
          controller: _searchController,
          autofocus: true,
          onChanged: _filterProfiles,
          decoration: InputDecoration(
            hintText: "Search name, location, caste...",
            hintStyle: TextStyle(
              color: const Color(0xFF820815).withValues(alpha: 0.5),
            ),
            border: InputBorder.none,
          ),
        ),
      ),
      body: _filteredProfiles.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _filteredProfiles.length,
              itemBuilder: (context, index) {
                return _buildProfileCard(_filteredProfiles[index]);
              },
            ),
    );
  }

  Widget _buildProfileCard(UserProfile profile) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 4,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProfileDetailScreen(userId: profile.id),
            ),
          );
        },
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  profile.photos.isNotEmpty
                      ? profile.photos[0]
                      : 'https://via.placeholder.com/100',
                  height: 80,
                  width: 80,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${profile.name}, ${profile.age}",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF820815),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${profile.occupation} • ${profile.location}",
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Color(0xFF820815)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _searchController.text.isEmpty ? Icons.search : Icons.search_off,
            size: 64,
            color: const Color(0xFF820815).withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            _searchController.text.isEmpty
                ? "Start searching for matches"
                : "No matches found",
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF820815),
            ),
          ),
        ],
      ),
    );
  }
}
