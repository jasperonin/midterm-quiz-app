// lib/modules/dashboard/widgets/quick_actions.dart
import 'package:flutter/material.dart';

class QuickActions extends StatelessWidget {
  const QuickActions({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Actions',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildActionButton(
                icon: Icons.add_circle,
                label: 'Create Quiz',
                color: Colors.blue,
                onTap: () {
                  // Navigate to create quiz
                },
              ),
              _buildActionButton(
                icon: Icons.people,
                label: 'Add Students',
                color: Colors.green,
                onTap: () {
                  // Navigate to add students
                },
              ),
              _buildActionButton(
                icon: Icons.analytics,
                label: 'View Reports',
                color: Colors.orange,
                onTap: () {
                  // Navigate to reports
                },
              ),
              _buildActionButton(
                icon: Icons.schedule,
                label: 'Schedule Quiz',
                color: Colors.purple,
                onTap: () {
                  // Navigate to schedule
                },
              ),
              _buildActionButton(
                icon: Icons.settings,
                label: 'Settings',
                color: Colors.grey,
                onTap: () {
                  // Navigate to settings
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
