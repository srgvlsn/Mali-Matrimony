import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProfileHeader(),
          const SizedBox(height: 32),
          _buildDetailSection("Account Information", [
            {"label": "Full Name", "value": "Rahul Kumar"},
            {"label": "Phone", "value": "+91 98765 43210"},
            {"label": "Email", "value": "rahul.kumar@example.com"},
          ]),
          const SizedBox(height: 24),
          _buildDetailSection("Personal Details", [
            {"label": "Gender", "value": "Male"},
            {"label": "Date of Birth", "value": "15 June 1994"},
            {"label": "Height", "value": "5'11\""},
            {"label": "Marital Status", "value": "Never Married"},
          ]),
          const SizedBox(height: 24),
          _buildDetailSection("Community & Education", [
            {"label": "Caste", "value": "Mali"},
            {"label": "Mother Tongue", "value": "Hindi"},
            {"label": "Education", "value": "MBA in Finance"},
            {"label": "Profession", "value": "Investment Banker"},
          ]),
          const SizedBox(height: 40),
          _buildLogoutButton(context),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Center(
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF820815), width: 3),
                ),
                child: const CircleAvatar(
                  radius: 60,
                  backgroundImage: NetworkImage(
                    'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=1000&auto=format&fit=crop',
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
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
