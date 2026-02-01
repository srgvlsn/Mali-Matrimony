import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/profile_service.dart';
import 'login_screen.dart';

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileService>(
      builder: (context, profileService, child) {
        // For demonstration, we'll use 'user_456' as the current user (Rahul Kumar)
        final profile = profileService.getProfileById('user_456');

        if (profile == null) {
          return const Center(child: Text("Profile not found"));
        }

        final completion = profile.completionPercentage;

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (completion >= 1.0)
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle, color: Colors.green, size: 14),
                        SizedBox(width: 6),
                        Text(
                          "Profile 100% Completed",
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              _buildProfileHeader(
                completion,
                profile.photos.isNotEmpty ? profile.photos[0] : null,
              ),
              const SizedBox(height: 32),
              _buildDetailSection("Account Information", [
                {"label": "Full Name", "value": profile.name},
                {"label": "Location", "value": profile.location},
                {"label": "Mother Tongue", "value": profile.motherTongue},
              ]),
              const SizedBox(height: 24),
              _buildDetailSection("Personal Details", [
                {"label": "Gender", "value": profile.gender.name.toUpperCase()},
                {"label": "Age", "value": "${profile.age} yrs"},
                {"label": "Height", "value": "${profile.height}'"},
                {
                  "label": "Marital Status",
                  "value": profile.maritalStatus.name,
                },
              ]),
              const SizedBox(height: 24),
              _buildDetailSection("Community & Education", [
                {"label": "Caste", "value": profile.caste},
                {"label": "Sub-Caste", "value": profile.subCaste},
                {"label": "Education", "value": profile.education},
                {"label": "Profession", "value": profile.occupation},
              ]),
              const SizedBox(height: 40),
              _buildLogoutButton(context),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileHeader(double completion, String? imageUrl) {
    final showProgress = completion < 1.0;

    return Center(
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              if (showProgress)
                SizedBox(
                  width: 140,
                  height: 140,
                  child: CircularProgressIndicator(
                    value: completion,
                    strokeWidth: 4,
                    color: const Color(0xFF820815),
                    backgroundColor: const Color(
                      0xFF820815,
                    ).withValues(alpha: 0.1),
                  ),
                ),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: showProgress
                        ? Colors.transparent
                        : const Color(0xFF820815),
                    width: 3,
                  ),
                ),
                child: CircleAvatar(
                  radius: 60,
                  backgroundImage: imageUrl != null
                      ? NetworkImage(imageUrl)
                      : null,
                  child: imageUrl == null
                      ? const Icon(Icons.person, size: 60)
                      : null,
                ),
              ),
              Positioned(
                bottom: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Color(0xFF820815),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            "Rahul Kumar",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF820815),
            ),
          ),
          if (showProgress) ...[
            const SizedBox(height: 8),
            Text(
              "Profile Strength: ${(completion * 100).toInt()}%",
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF820815),
                fontWeight: FontWeight.w600,
              ),
            ),
          ] else
            const Text(
              "Premium Member",
              style: TextStyle(
                fontSize: 16,
                color: Colors.green,
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailSection(String title, List<Map<String, String>> details) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF820815),
            ),
          ),
        ),
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              children: details
                  .map((detail) => _buildDetailTile(detail))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailTile(Map<String, String> detail) {
    return ListTile(
      title: Text(
        detail['label']!,
        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
      ),
      subtitle: Text(
        detail['value']!,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
      trailing: IconButton(
        icon: const Icon(
          Icons.edit_outlined,
          size: 20,
          color: Color(0xFF820815),
        ),
        onPressed: () {
          // Implement edit logic
        },
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () async {
        await AuthService.instance.logout();
        if (!context.mounted) return;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      },
      icon: const Icon(Icons.logout),
      label: const Text("Logout"),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF820815),
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
      ),
    );
  }
}
