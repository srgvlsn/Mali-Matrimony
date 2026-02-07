import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared/shared.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
import 'payment_screen.dart';
import 'blocked_conversations_screen.dart';

class SettingsScreen extends StatefulWidget {
  final bool highlightMembership;

  const SettingsScreen({super.key, this.highlightMembership = false});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with SingleTickerProviderStateMixin {
  bool _isDeleting = false;
  late AnimationController _highlightController;
  late Animation<double> _scaleAnimation;

  Future<void> _updateSetting(String key, bool value) async {
    final authService = context.read<AuthService>();
    final originalUser = authService.currentUser;
    if (originalUser == null) return;

    // Build optimistic user object
    late UserProfile updatedUser;
    if (key == 'is_hidden') {
      updatedUser = originalUser.copyWith(isHidden: value);
    } else if (key == 'show_phone') {
      updatedUser = originalUser.copyWith(showPhone: value);
    } else if (key == 'show_email') {
      updatedUser = originalUser.copyWith(showEmail: value);
    } else {
      updatedUser = originalUser;
    }

    // Apply optimistic update
    BackendService.instance.updateCurrentUserLocally(updatedUser);
    authService.refresh();

    final response = await BackendService.instance.updateUserSettings(
      originalUser.id,
      {key: value},
    );

    if (!mounted) return;

    if (!response.success) {
      // Rollback on failure
      BackendService.instance.updateCurrentUserLocally(originalUser);
      authService.refresh();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response.message ?? 'Failed to update setting')),
      );
    }
    // No need to call refresh() on success because updateUserSettings
    // now updates the internal _currentUser in BackendService too.
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
  void initState() {
    super.initState();
    _highlightController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _scaleAnimation =
        TweenSequence<double>([
          TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.08), weight: 50),
          TweenSequenceItem(tween: Tween(begin: 1.08, end: 1.0), weight: 50),
        ]).animate(
          CurvedAnimation(
            parent: _highlightController,
            curve: Curves.easeInOut,
          ),
        );

    if (widget.highlightMembership == true) {
      _highlightController.repeat();
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          _highlightController.stop();
          _highlightController.value = 0;
        }
      });
    }
  }

  @override
  void dispose() {
    _highlightController.dispose();
    super.dispose();
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
                    const Divider(height: 1),
                    _buildActionTile(
                      "Blocked Users",
                      "Manage users you've blocked",
                      Icons.block_outlined,
                      Colors.orange,
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const BlockedConversationsScreen(),
                          ),
                        );
                      },
                    ),
                  ]),
                  const SizedBox(height: 32),
                  _buildSectionHeader("Membership"),
                  _buildPremiumStatusCard(user),
                  const SizedBox(height: 32),
                  _buildSectionHeader("Account Actions"),
                  _buildSettingCard([
                    _buildActionTile(
                      "Logout",
                      null, // subtitle
                      Icons.logout,
                      Colors.black87,
                      _handleLogout,
                    ),
                    const Divider(height: 1),
                    _buildActionTile(
                      "Delete Account",
                      null, // subtitle
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppStyles.radiusL),
      ),
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

  Widget _buildPremiumStatusCard(UserProfile user) {
    final card = _buildBasePremiumCard(user);

    if (widget.highlightMembership != true) return card;

    return AnimatedBuilder(
      animation: _highlightController,
      builder: (context, child) {
        return ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppStyles.radiusL),
              boxShadow: [
                BoxShadow(
                  color: AppStyles.primary.withValues(
                    alpha: 0.2 * _highlightController.value,
                  ),
                  blurRadius: 20 * _highlightController.value,
                  spreadRadius: 5 * _highlightController.value,
                ),
              ],
            ),
            child: card,
          ),
        );
      },
    );
  }

  Widget _buildBasePremiumCard(UserProfile user) {
    if (!user.isPremium) {
      return Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppStyles.radiusL),
        ),
        elevation: 2,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 12,
          ),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.star_outline, color: Colors.grey),
          ),
          title: const Text(
            "Free Member",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          subtitle: const Text("Upgrade to see more profiles"),
          trailing: TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PaymentScreen()),
              );
            },
            child: const Text("Upgrade"),
          ),
        ),
      );
    }

    final expiry = user.premiumExpiryDate;
    final remainingDays = expiry != null
        ? expiry.difference(DateTime.now()).inDays
        : 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppStyles.primary, AppStyles.primary.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppStyles.radiusL),
        boxShadow: [
          BoxShadow(
            color: AppStyles.primary.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.star, color: Colors.white, size: 16),
                    SizedBox(width: 6),
                    Text(
                      "PREMIUM ACTIVE",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.verified_user, color: Colors.white70, size: 24),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            "Yearly Subscription",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          if (expiry != null)
            Text(
              "Next payment on ${DateFormatter.formatShortDate(expiry)}",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          const SizedBox(height: 16),
          Container(
            height: 4,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(AppStyles.radiusS),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: (remainingDays / 365).clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppStyles.radiusS),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "$remainingDays days remaining",
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile(
    String title,
    String? subtitle,
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
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            )
          : null,
      trailing: const Icon(Icons.chevron_right, size: 20),
      onTap: onTap,
    );
  }
}
