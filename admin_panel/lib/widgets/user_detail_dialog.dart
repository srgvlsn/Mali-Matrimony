import 'package:flutter/material.dart';
import 'package:shared/shared.dart';
import 'user_edit_dialog.dart';

class UserDetailDialog extends StatelessWidget {
  final UserProfile user;

  const UserDetailDialog({super.key, required this.user});

  static Future<void> show(BuildContext context, UserProfile user) {
    return showDialog(
      context: context,
      builder: (context) => UserDetailDialog(user: user),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        width: 600,
        padding: const EdgeInsets.all(32),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "User Detail Review",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppStyles.primary,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const Divider(height: 32),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundImage: user.photos.isNotEmpty
                        ? NetworkImage(
                            ApiService.instance.resolveUrl(user.photos[0]),
                          )
                        : null,
                    child: user.photos.isEmpty
                        ? const Icon(Icons.person, size: 60)
                        : null,
                  ),
                  const SizedBox(width: 32),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.name,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "${user.age} yrs • ${user.gender.name.toUpperCase()}",
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildBadge(
                          user.isVerified ? "VERIFIED" : "PENDING",
                          user.isVerified ? Colors.green : Colors.orange,
                        ),
                        const SizedBox(height: 8),
                        if (user.isPremium)
                          _buildBadge("PREMIUM", Colors.purple),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              _buildInfoSection("Bio", user.bio),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildInfoSection("Location", user.location)),
                  Expanded(
                    child: _buildInfoSection("Occupation", user.occupation),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildInfoSection("Caste", user.caste)),
                  Expanded(child: _buildInfoSection("Income", user.income)),
                ],
              ),
              const SizedBox(height: 16),
              _buildInfoSection(
                "Registration Date",
                DateFormatter.formatLongDate(user.createdAt),
              ),
              const Divider(height: 48),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Close"),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: () async {
                      Navigator.pop(context);
                      final result = await UserEditDialog.show(context, user);
                      if (result == true) {
                        // Dialog was closed, changes were saved
                      }
                    },
                    style: AppStyles.primaryButtonStyle,
                    icon: const Icon(Icons.edit),
                    label: const Text("Edit User"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInfoSection(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
