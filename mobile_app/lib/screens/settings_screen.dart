import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared/shared.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isDeleting = false;

  Future<void> _updateSetting(String key, bool value) async {
    final user = context.read<AuthService>().currentUser;
    if (user == null) return;

    final response = await BackendService.instance.updateUserSettings(user.id, {
      key: value,
    });

    if (!mounted) return;

    if (response.success) {
      context.read<AuthService>().refresh();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response.message ?? 'Failed to update setting')),
      );
    }
  }

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("Logout"),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await context.read<AuthService>().logout();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  Future<void> _handleDeleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          "Delete Account",
          style: TextStyle(color: Colors.red),
        ),
        content: const Text(
          "WARNING: This action is permanent. All your data including photos, messages, and interests will be deleted forever.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("Delete Everything"),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      setState(() => _isDeleting = true);
      final user = context.read<AuthService>().currentUser;
      if (user != null) {
        final response = await BackendService.instance.deleteAccount(user.id);
        if (response.success && mounted) {
          await context.read<AuthService>().logout();
          if (mounted) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const LoginScreen()),
              (route) => false,
            );
          }
        } else if (mounted) {
          setState(() => _isDeleting = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.message ?? 'Failed to delete account'),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles.background,
      appBar: AppBar(
        title: const Text(
          "Settings & Privacy",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppStyles.primary,
          ),
        ),
        backgroundColor: AppStyles.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppStyles.primary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<AuthService>(
        builder: (context, authService, child) {
          final user = authService.currentUser;
          if (user == null) return const SizedBox.shrink();

          return Stack(
            children: [
              ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  _buildSectionHeader("Privacy"),
                  _buildSettingCard([
                    _buildSwitchTile(
                      "Hide Profile",
                      "Only people you've interacted with can see you",
                      user.isHidden,
                      (val) => _updateSetting('is_hidden', val),
                    ),
                    const Divider(height: 1),
                    _buildSwitchTile(
                      "Show Phone",
                      "Allow others to see your contact number",
                      user.showPhone,
                      (val) => _updateSetting('show_phone', val),
                    ),
                    const Divider(height: 1),
                    _buildSwitchTile(
                      "Show Email",
                      "Allow others to see your email address",
                      user.showEmail,
                      (val) => _updateSetting('show_email', val),
                    ),
                  ]),
                  const SizedBox(height: 32),
                  _buildSectionHeader("Account Actions"),
                  _buildSettingCard([
                    _buildActionTile(
                      "Logout",
                      Icons.logout,
                      Colors.black87,
                      _handleLogout,
                    ),
                    const Divider(height: 1),
                    _buildActionTile(
                      "Delete Account",
                      Icons.delete_forever_outlined,
                      Colors.red,
                      _handleDeleteAccount,
                    ),
                  ]),
                  const SizedBox(height: 40),
                  const Center(
                    child: Text(
                      "Version 0.6.8 (Beta)",
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ),
                ],
              ),
              if (_isDeleting)
                Container(
                  color: Colors.black26,
                  child: const Center(child: CircularProgressIndicator()),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppStyles.primary,
        ),
      ),
    );
  }

  Widget _buildSettingCard(List<Widget> children) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 2,
      child: Column(children: children),
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged,
  ) {
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
      ),
      activeThumbColor: AppStyles.primary,
      activeTrackColor: AppStyles.primary.withValues(alpha: 0.5),
    );
  }

  Widget _buildActionTile(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        title,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, size: 20),
      onTap: onTap,
    );
  }
}
