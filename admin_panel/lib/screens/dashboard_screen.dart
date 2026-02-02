import 'package:flutter/material.dart';
import '../services/admin_service.dart';
import 'package:shared/shared.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  late Future<Map<String, dynamic>> _analyticsFuture;

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
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
              const Text(
                "Dashboard Overview",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppStyles.primary,
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

              return Column(
                children: [
                  Row(
                    children: [
                      _buildStatCard(
                        context,
                        "Total Users",
                        "${analytics['total_users'] ?? 0}",
                        Icons.people,
                        Colors.blue,
                      ),
                      const SizedBox(width: 24),
                      _buildStatCard(
                        context,
                        "Verified Users",
                        "${analytics['verified_users'] ?? 0}",
                        Icons.verified,
                        Colors.green,
                      ),
                      const SizedBox(width: 24),
                      _buildStatCard(
                        context,
                        "Premium Users",
                        "${analytics['premium_users'] ?? 0}",
                        Icons.star,
                        Colors.purple,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      _buildStatCard(
                        context,
                        "Pending Verification",
                        "${analytics['pending_verification'] ?? 0}",
                        Icons.pending_actions,
                        Colors.orange,
                      ),
                      const SizedBox(width: 24),
                      _buildStatCard(
                        context,
                        "Recent (7 days)",
                        "${analytics['recent_registrations'] ?? 0}",
                        Icons.new_releases,
                        Colors.teal,
                      ),
                      const SizedBox(width: 24),
                      _buildStatCard(
                        context,
                        "Gender Ratio",
                        "${analytics['male_users'] ?? 0}M / ${analytics['female_users'] ?? 0}F",
                        Icons.people_outline,
                        Colors.indigo,
                      ),
                    ],
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
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: AppStyles.cardShadow,
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
                    style: const TextStyle(
                      color: AppStyles.primary,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
