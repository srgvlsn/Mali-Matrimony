import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _autoVerification = false;
  final String _adminName = "Super Admin";

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Settings & Profile",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView(
              children: [
                _buildSection("Admin Profile"),
                _buildProfileTile(),
                const SizedBox(height: 32),
                _buildSection("Platform Settings"),
                _buildSwitchTile(
                  "Enable Push Notifications",
                  "Send notifications to users on matches/interests.",
                  _notificationsEnabled,
                  (v) => setState(() => _notificationsEnabled = v),
                ),
                _buildSwitchTile(
                  "Smart Verification",
                  "Automatically flag profiles with suspicious keywords.",
                  _autoVerification,
                  (v) => setState(() => _autoVerification = v),
                ),
                const SizedBox(height: 32),
                _buildSection("System"),
                _buildActionTile(
                  Icons.history,
                  "View System Logs",
                  "Last login: 5 mins ago",
                ),
                _buildActionTile(
                  Icons.security,
                  "Security Audit",
                  "System health: Excellent",
                ),
                _buildActionTile(
                  Icons.info_outline,
                  "Platform Info",
                  "Version 1.0.0-beta",
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.6),
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildProfileTile() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isNarrow = constraints.maxWidth < 450;

        final content = Row(
          children: [
            const CircleAvatar(
              radius: 30,
              backgroundColor: AppStyles.primary,
              child: Icon(Icons.person, color: Colors.white, size: 30),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _adminName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "admin@malimatrimony.com",
                    style: TextStyle(
                      color: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            if (!isNarrow)
              OutlinedButton(
                onPressed: () {},
                style: AppStyles.outlinedButtonStyle,
                child: const Text("Edit"),
              ),
          ],
        );

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color,
            borderRadius: BorderRadius.circular(AppStyles.radiusL),
            boxShadow: Theme.of(context).brightness == Brightness.dark
                ? []
                : AppStyles.cardShadow,
          ),
          child: isNarrow
              ? Column(
                  children: [
                    content,
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {},
                        style: AppStyles.outlinedButtonStyle,
                        child: const Text("Edit"),
                      ),
                    ),
                  ],
                )
              : content,
        );
      },
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppStyles.radiusL),
        boxShadow: AppStyles.cardShadow,
      ),
      child: SwitchListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        value: value,
        onChanged: onChanged,
        activeThumbColor: AppStyles.primary,
        activeTrackColor: AppStyles.primary.withValues(alpha: 0.5),
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      ),
    );
  }

  Widget _buildActionTile(IconData icon, String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(AppStyles.radiusL),
        boxShadow: Theme.of(context).brightness == Brightness.dark
            ? []
            : AppStyles.cardShadow,
      ),
      child: ListTile(
        leading: Icon(icon, color: AppStyles.primary),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
        onTap: () {},
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      ),
    );
  }
}
