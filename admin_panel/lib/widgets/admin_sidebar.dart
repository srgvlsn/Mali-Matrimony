import 'package:flutter/material.dart';
import 'package:shared/shared.dart';
import '../services/admin_theme_service.dart';

class AdminSidebar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const AdminSidebar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 250,
      color: theme.cardTheme.color ?? theme.colorScheme.surface,
      child: Column(
        children: [
          // Header / Logo
          Container(
            height: 80,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: theme.dividerColor)),
            ),
            child: Text(
              "Mali Matrimony\nAdmin Portal",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
          ),

          // Menu Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 20),
              children: [
                _buildMenuItem(
                  context,
                  0,
                  Icons.dashboard_outlined,
                  Icons.dashboard,
                  "Dashboard",
                ),
                _buildMenuItem(
                  context,
                  1,
                  Icons.verified_user_outlined,
                  Icons.verified_user,
                  "Verification",
                ),
                _buildMenuItem(
                  context,
                  2,
                  Icons.people_outline,
                  Icons.people,
                  "All Users",
                ),
                _buildMenuItem(
                  context,
                  3,
                  Icons.settings_outlined,
                  Icons.settings,
                  "Settings",
                ),
              ],
            ),
          ),

          // Theme Toggle
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ValueListenableBuilder<ThemeMode>(
              valueListenable: AdminThemeService.instance.themeMode,
              builder: (context, mode, child) {
                final isDark = mode == ThemeMode.dark;
                return ListTile(
                  dense: true,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  tileColor: theme.colorScheme.primary.withValues(alpha: 0.05),
                  leading: Icon(
                    isDark ? Icons.dark_mode : Icons.light_mode,
                    color: theme.colorScheme.primary,
                  ),
                  title: Text(
                    isDark ? "Dark Mode" : "Light Mode",
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  trailing: Switch(
                    value: isDark,
                    onChanged: (_) => AdminThemeService.instance.toggleTheme(),
                    activeThumbColor: theme.colorScheme.primary,
                  ),
                );
              },
            ),
          ),

          // Footer
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: theme.dividerColor)),
            ),
            child: Column(
              children: [
                Text(
                  "Mali Matrimony Admin",
                  style: TextStyle(
                    color: theme.textTheme.bodySmall?.color?.withValues(
                      alpha: 0.5,
                    ),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "v1.0.0-beta",
                  style: TextStyle(
                    color: theme.textTheme.bodySmall?.color?.withValues(
                      alpha: 0.4,
                    ),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    int index,
    IconData iconOutline,
    IconData iconFilled,
    String title,
  ) {
    final isSelected = selectedIndex == index;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onItemSelected(index),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppStyles.primary.withValues(alpha: 0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  isSelected ? iconFilled : iconOutline,
                  color: isSelected ? AppStyles.primary : Colors.grey[600],
                  size: 22,
                ),
                const SizedBox(width: 16),
                Text(
                  title,
                  style: TextStyle(
                    color: isSelected ? AppStyles.primary : Colors.grey[800],
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
