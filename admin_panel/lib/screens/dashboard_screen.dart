import 'dart:async';
import 'package:flutter/material.dart';
import '../services/admin_service.dart';
import '../services/admin_socket_service.dart';
import 'package:shared/shared.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  late Future<Map<String, dynamic>> _analyticsFuture;
  StreamSubscription? _socketSubscription;

  @override
  void initState() {
    super.initState();
    _loadAnalytics();

    // Listen for real-time events to refresh analytics
    _socketSubscription = AdminSocketService.instance.eventStream.listen((
      event,
    ) {
      if (!mounted) return;

      // Refresh on any event that affects dashboard metrics
      _loadAnalytics();

      if (event.type == 'payment_completed') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Premium upgrade detected: ${event.userName}. Analytics updated.",
            ),
            backgroundColor: AppStyles.primary,
          ),
        );
      } else if (event.type == 'user_registered') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("New Registration: ${event.userName}"),
            backgroundColor: Colors.green,
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _socketSubscription?.cancel();
    super.dispose();
  }

  void _loadAnalytics() {
    setState(() {
      _analyticsFuture = AdminService.instance.getAnalyticsData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Dashboard Overview",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _loadAnalytics,
                tooltip: 'Refresh Analytics',
              ),
            ],
          ),
          const SizedBox(height: 24),
          FutureBuilder<Map<String, dynamic>>(
            future: _analyticsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(48.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text('Error loading analytics: ${snapshot.error}'),
                );
              }

              final analytics = snapshot.data ?? {};

              return Wrap(
                spacing: 24,
                runSpacing: 24,
                children: [
                  _buildStatCard(
                    context,
                    "Total Users",
                    "${analytics['total_users'] ?? 0}",
                    Icons.people,
                    Colors.blue,
                  ),
                  _buildStatCard(
                    context,
                    "Verified Users",
                    "${analytics['verified_users'] ?? 0}",
                    Icons.verified,
                    Colors.green,
                  ),
                  _buildStatCard(
                    context,
                    "Premium Users",
                    "${analytics['premium_users'] ?? 0}",
                    Icons.star,
                    Colors.purple,
                  ),
                  _buildStatCard(
                    context,
                    "Pending Verification",
                    "${analytics['pending_verification'] ?? 0}",
                    Icons.pending_actions,
                    Colors.orange,
                  ),
                  _buildStatCard(
                    context,
                    "Recent (7 days)",
                    "${analytics['recent_registrations'] ?? 0}",
                    Icons.new_releases,
                    Colors.teal,
                  ),
                  _buildStatCard(
                    context,
                    "Gender Ratio",
                    "${analytics['male_users'] ?? 0}M / ${analytics['female_users'] ?? 0}F",
                    Icons.people_outline,
                    Colors.indigo,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      constraints: const BoxConstraints(minWidth: 280, maxWidth: 350),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(AppStyles.radiusL),
        boxShadow: isDark ? [] : AppStyles.cardShadow,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 32),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  value,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
