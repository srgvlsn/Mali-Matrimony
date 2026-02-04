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
              const Text(
                "All Users",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
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
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: AppStyles.cardShadow,
              ),
              clipBehavior: Clip.antiAlias,
              child: SingleChildScrollView(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowColor: WidgetStateProperty.all(
                      AppStyles.primary.withValues(alpha: 0.05),
                    ),
                    columns: const [
                      DataColumn(
                        label: Text(
                          "Name",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppStyles.primary,
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          "Age / Gender",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppStyles.primary,
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          "Caste",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppStyles.primary,
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          "Status",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppStyles.primary,
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          "Payment",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppStyles.primary,
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          "Joined",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppStyles.primary,
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          "Actions",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppStyles.primary,
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
                                color: user.isVerified
                                    ? Colors.green.withValues(alpha: 0.1)
                                    : Colors.orange.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: Text(
                                user.isVerified ? "Verified" : "Pending",
                                style: TextStyle(
                                  color: user.isVerified
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
                                  icon: const Icon(
                                    Icons.block,
                                    color: Colors.red,
                                  ),
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          "${user.name} has been blocked",
                                        ),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  },
                                  tooltip: "Block User",
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
