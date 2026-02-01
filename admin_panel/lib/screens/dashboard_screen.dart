import 'package:flutter/material.dart';
import '../services/admin_mock_service.dart';
import '../utils/app_styles.dart';
import '../widgets/mock_analytics_chart.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // In a real app, you'd use Provider/State management here
    final service = AdminMockService.instance;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Dashboard Overview",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppStyles.primary,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _buildStatCard(
                context,
                "Total Users",
                "${service.totalUsers}",
                Icons.people,
                Colors.blue,
              ),
              const SizedBox(width: 24),
              _buildStatCard(
                context,
                "Pending Requests",
                "${service.pendingVerifications}",
                Icons.pending_actions,
                Colors.orange,
              ),
              const SizedBox(width: 24),
              _buildStatCard(
                context,
                "Verified Users",
                "${service.verifiedUsers}",
                Icons.verified,
                Colors.green,
              ),
            ],
          ),
          const SizedBox(height: 32),
          const MockAnalyticsChart(),
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
            Column(
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
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
