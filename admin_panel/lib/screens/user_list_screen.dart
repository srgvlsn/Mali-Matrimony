import 'dart:async';
import 'package:flutter/material.dart';
import '../services/admin_service.dart';
import '../services/admin_socket_service.dart';
import 'package:shared/shared.dart';
import '../widgets/user_detail_dialog.dart';
import '../widgets/user_edit_dialog.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  List<UserProfile> _users = [];
  List<UserProfile> _filteredUsers = []; // For search
  StreamSubscription? _socketSubscription;

  @override
  void initState() {
    super.initState();
    _loadUsers();

    // Listen for real-time events via stream (multi-listener friendly)
    _socketSubscription = AdminSocketService.instance.eventStream.listen((
      event,
    ) {
      if (!mounted) return;

      if (event.type == 'payment_completed') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("New Premium Member: ${event.userName}"),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: "REFRESH",
              textColor: Colors.white,
              onPressed: _loadUsers,
            ),
          ),
        );
        _loadUsers();
      } else if (event.type == 'profile_updated' ||
          event.type == 'user_registered' ||
          event.type == 'profile_deleted') {
        if (event.type == 'user_registered') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("New User Registered: ${event.userName}"),
              backgroundColor: AppStyles.primary,
            ),
          );
        }
        _loadUsers();
      }
    });
  }

  @override
  void dispose() {
    _socketSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    final fetchedUsers = await AdminService.instance.getUsers();
    if (!mounted) {
      debugPrint("⚠️ UserListScreen: Not mounted, skipping state update.");
      return;
    }
    setState(() {
      _users = fetchedUsers;
      _filteredUsers = _users;
    });
    debugPrint("✅ UserListScreen: Loaded ${_users.length} users.");
  }

  // void _refreshData() {
  //   _loadUsers();
  // }

  @override
  Widget build(BuildContext context) {
    final users = _filteredUsers;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 24,
            runSpacing: 16,
            crossAxisAlignment: WrapCrossAlignment.center,
            alignment: WrapAlignment.spaceBetween,
            children: [
              Text(
                "All Users",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  // Mock export action
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Exporting Users...")),
                  );
                },
                icon: const Icon(Icons.download),
                label: const Text("Export CSV"),
                style: AppStyles.primaryButtonStyle,
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color,
                borderRadius: BorderRadius.circular(AppStyles.radiusL),
                boxShadow: Theme.of(context).brightness == Brightness.dark
                    ? []
                    : AppStyles.cardShadow,
              ),
              clipBehavior: Clip.antiAlias,
              child: SingleChildScrollView(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowColor: WidgetStateProperty.all(
                      Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.1),
                    ),
                    columns: [
                      DataColumn(
                        label: Text(
                          "Name",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          "Age / Gender",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          "Caste",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          "Status",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          "Payment",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          "Joined",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          "Actions",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                    rows: users.map((user) {
                      return DataRow(
                        cells: [
                          DataCell(
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 16,
                                  backgroundImage: user.photos.isNotEmpty
                                      ? NetworkImage(
                                          ApiService.instance.resolveUrl(
                                            user.photos[0],
                                          ),
                                        )
                                      : null,
                                  child: user.photos.isEmpty
                                      ? const Icon(Icons.person, size: 16)
                                      : null,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  user.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: AppStyles.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          DataCell(Text("${user.age} / ${user.gender.name}")),
                          DataCell(Text(user.caste ?? "Mali")),
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: !user.isActive
                                    ? Colors.black.withValues(alpha: 0.1)
                                    : user.isVerified
                                    ? Colors.green.withValues(alpha: 0.1)
                                    : Colors.orange.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: Text(
                                !user.isActive
                                    ? "Blocked"
                                    : user.isVerified
                                    ? "Verified"
                                    : "Pending",
                                style: TextStyle(
                                  color: !user.isActive
                                      ? Colors.black87
                                      : user.isVerified
                                      ? Colors.green
                                      : Colors.orange,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: user.isPremium
                                    ? Colors.purple.withValues(alpha: 0.1)
                                    : Colors.grey.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: Text(
                                user.isPremium ? "Premium" : "Free",
                                style: TextStyle(
                                  color: user.isPremium
                                      ? Colors.purple
                                      : Colors.grey[700],
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              DateFormatter.formatShortDate(user.createdAt),
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                          DataCell(
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.visibility),
                                  onPressed: () =>
                                      UserDetailDialog.show(context, user),
                                  tooltip: "View Details",
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit,
                                    color: AppStyles.primary,
                                  ),
                                  onPressed: () async {
                                    final result = await UserEditDialog.show(
                                      context,
                                      user,
                                    );
                                    if (result == true && context.mounted) {
                                      _loadUsers();
                                    }
                                  },
                                  tooltip: "Edit User",
                                ),
                                IconButton(
                                  icon: Icon(
                                    user.isActive
                                        ? Icons.block
                                        : Icons.check_circle_outline,
                                    color: user.isActive
                                        ? Colors.red
                                        : Colors.green,
                                  ),
                                  onPressed: () async {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        title: Text(
                                          user.isActive
                                              ? "Block User?"
                                              : "Unblock User?",
                                        ),
                                        content: Text(
                                          user.isActive
                                              ? "Are you sure you want to block ${user.name}? They will not be able to interact with others."
                                              : "Restore ${user.name}'s account access?",
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(ctx, false),
                                            child: const Text("CANCEL"),
                                          ),
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(ctx, true),
                                            child:
                                                TextTheme.of(
                                                      context,
                                                    ).labelLarge?.color !=
                                                    null
                                                ? Text(
                                                    user.isActive
                                                        ? "BLOCK"
                                                        : "UNBLOCK",
                                                    style: TextStyle(
                                                      color: user.isActive
                                                          ? Colors.red
                                                          : Colors.green,
                                                    ),
                                                  )
                                                : Text(
                                                    user.isActive
                                                        ? "BLOCK"
                                                        : "UNBLOCK",
                                                  ),
                                          ),
                                        ],
                                      ),
                                    );

                                    if (confirm == true) {
                                      if (user.isActive) {
                                        await AdminService.instance.blockUser(
                                          user.id,
                                        );
                                      } else {
                                        // Unblock is just copyWith(isActive: true)
                                        final updated = user.copyWith(
                                          isActive: true,
                                        );
                                        await AdminService.instance.updateUser(
                                          updated,
                                        );
                                      }
                                      await _loadUsers();
                                      if (!context.mounted) return;
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            user.isActive
                                                ? "${user.name} Blocked"
                                                : "${user.name} Unblocked",
                                          ),
                                          backgroundColor: user.isActive
                                              ? Colors.red
                                              : Colors.green,
                                        ),
                                      );
                                    }
                                  },
                                  tooltip: user.isActive
                                      ? "Block User"
                                      : "Unblock User",
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
