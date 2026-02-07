import 'dart:async';
import 'package:flutter/material.dart';
import '../services/admin_service.dart';
import '../services/admin_socket_service.dart';
import 'package:shared/shared.dart';

class VerificationScreen extends StatefulWidget {
  const VerificationScreen({super.key});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  List<UserProfile> _pendingUsers = [];
  StreamSubscription? _socketSubscription;

  @override
  void initState() {
    super.initState();
    _loadData();

    // Listen for real-time events via stream
    _socketSubscription = AdminSocketService.instance.eventStream.listen((
      event,
    ) {
      if (!mounted) return;

      // Verification status changes often trigger a profile_updated event
      if (event.type == 'profile_updated') {
        _loadData();
      }
    });
  }

  @override
  void dispose() {
    _socketSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadData() async {
    final fetchedUsers = await AdminService.instance.getPendingUsers();
    if (!mounted) return;
    setState(() {
      _pendingUsers = fetchedUsers;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_pendingUsers.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle_outline, size: 60, color: Colors.green),
            SizedBox(height: 16),
            Text(
              "No pending verifications",
              style: TextStyle(
                fontSize: 18,
                color: Theme.of(
                  context,
                ).textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Verification Queue",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView.separated(
              itemCount: _pendingUsers.length,
              separatorBuilder: (ctx, i) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final user = _pendingUsers[index];
                return Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardTheme.color,
                    borderRadius: BorderRadius.circular(AppStyles.radiusL),
                    boxShadow: Theme.of(context).brightness == Brightness.dark
                        ? []
                        : AppStyles.cardShadow,
                  ),
                  child: LayoutBuilder(
                    builder: (context, cardConstraints) {
                      final bool isNarrow = cardConstraints.maxWidth < 600;

                      final detailsWidget = Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "${user.age} yrs • ${user.occupation} • ${user.location}",
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.color
                                  ?.withValues(alpha: 0.7),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Caste: ${user.caste} (${user.subCaste})",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      );

                      final actionsContent = Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          OutlinedButton.icon(
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text("Reject User?"),
                                  content: Text(
                                    "Are you sure you want to reject ${user.name}? This will delete their profile permanentlly.",
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(ctx, false),
                                      child: const Text("CANCEL"),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx, true),
                                      child: const Text(
                                        "REJECT",
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ),
                                  ],
                                ),
                              );

                              if (confirm == true) {
                                await AdminService.instance.rejectUser(user.id);
                                await _loadData();
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("${user.name} Rejected"),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            },
                            icon: const Icon(Icons.close, color: Colors.red),
                            label: const Text(
                              "Reject",
                              style: TextStyle(color: Colors.red),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.red),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(100),
                              ),
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: () async {
                              await AdminService.instance.verifyUser(user.id);
                              await _loadData();
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("${user.name} Verified"),
                                  backgroundColor: Colors.green,
                                  duration: const Duration(seconds: 1),
                                ),
                              );
                            },
                            icon: const Icon(Icons.check, color: Colors.white),
                            label: const Text("Approve"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(100),
                              ),
                            ),
                          ),
                        ],
                      );

                      if (isNarrow) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 30,
                                  backgroundColor: Colors.grey[200],
                                  backgroundImage: user.photos.isNotEmpty
                                      ? NetworkImage(
                                          ApiService.instance.resolveUrl(
                                            user.photos[0],
                                          ),
                                        )
                                      : null,
                                  child: user.photos.isEmpty
                                      ? Icon(
                                          Icons.person,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary
                                              .withValues(alpha: 0.5),
                                        )
                                      : null,
                                ),
                                const SizedBox(width: 20),
                                Expanded(child: detailsWidget),
                              ],
                            ),
                            const SizedBox(height: 20),
                            actionsContent,
                          ],
                        );
                      }

                      return Row(
                        children: [
                          // Avatar
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.grey[200],
                            backgroundImage: user.photos.isNotEmpty
                                ? NetworkImage(
                                    ApiService.instance.resolveUrl(
                                      user.photos[0],
                                    ),
                                  )
                                : null,
                            child: user.photos.isEmpty
                                ? const Icon(Icons.person, color: Colors.grey)
                                : null,
                          ),
                          const SizedBox(width: 20),
                          // Details
                          Expanded(child: detailsWidget),
                          const SizedBox(width: 20),
                          // Actions
                          actionsContent,
                        ],
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
