// lib/shared/widgets/layouts/sidebar_layout.dart
import 'package:flutter/material.dart';
import '../../config/routes.dart';
import '../../utils/navigation_helper.dart';

class SidebarLayout extends StatelessWidget {
  final String teacherId;
  final String teacherName;
  final String currentRoute;
  final Widget child;

  const SidebarLayout({
    Key? key,
    required this.teacherId,
    required this.teacherName,
    required this.currentRoute,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Sidebar - Wrapped in Material
        Material(
          // Add Material wrapper
          color: Colors.white,
          child: Container(
            width: 260,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                // Teacher Profile
                _buildProfile(),

                // Navigation Menu
                _buildNavMenu(context),

                const Spacer(),

                // Logout Button
                _buildLogoutButton(context),
              ],
            ),
          ),
        ),

        // Main Content
        Expanded(
          child: Container(color: Colors.grey.shade50, child: child),
        ),
      ],
    );
  }

  Widget _buildProfile() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.blue.shade100,
            child: const Icon(Icons.person, size: 40, color: Colors.blue),
          ),
          const SizedBox(height: 10),
          Text(
            teacherName,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Text('Instructor', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildNavMenu(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          _buildNavItem(
            context,
            Icons.dashboard,
            'Dashboard',
            AppRoutes.dashboard,
            isSelected: currentRoute == AppRoutes.dashboard,
          ),
          _buildNavItem(
            context,
            Icons.quiz,
            'Quizzes',
            AppRoutes.quizzes,
            isSelected: currentRoute == AppRoutes.quizzes,
          ),
          _buildNavItem(
            context,
            Icons.people,
            'Students',
            AppRoutes.students,
            isSelected: currentRoute == AppRoutes.students,
          ),
          _buildNavItem(
            context,
            Icons.analytics,
            'Analytics',
            AppRoutes.analytics,
            isSelected: currentRoute == AppRoutes.analytics,
          ),
          _buildNavItem(
            context,
            Icons.settings,
            'Settings',
            AppRoutes.settings,
            isSelected: currentRoute == AppRoutes.settings,
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    IconData icon,
    String label,
    String route, {
    bool isSelected = false,
  }) {
    return Container(
      width: double.infinity,
      color: isSelected ? Colors.blue.withOpacity(0.1) : Colors.transparent,
      child: ListTile(
        leading: Icon(icon, color: isSelected ? Colors.blue : Colors.grey),
        title: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.blue : Colors.grey[700],
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        selected: isSelected,
        onTap: () {
          if (!isSelected) {
            _navigateToRoute(context, route);
          }
        },
      ),
    );
  }

  void _navigateToRoute(BuildContext context, String route) {
    switch (route) {
      case AppRoutes.dashboard:
        Navigator.pushReplacementNamed(
          context,
          AppRoutes.dashboard,
          arguments: {'teacherId': teacherId, 'teacherName': teacherName},
        );
        break;
      case AppRoutes.quizzes:
        Navigator.pushReplacementNamed(context, AppRoutes.quizzes);
        break;
      case AppRoutes.students:
        Navigator.pushReplacementNamed(
          context,
          AppRoutes.students,
          arguments: {'teacherId': teacherId},
        );
        break;
      case AppRoutes.analytics:
        Navigator.pushReplacementNamed(context, AppRoutes.analytics);
        break;
      case AppRoutes.settings:
        Navigator.pushReplacementNamed(context, AppRoutes.settings);
        break;
    }
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: OutlinedButton.icon(
        onPressed: () {
          _showLogoutDialog(context);
        },
        icon: const Icon(Icons.logout),
        label: const Text('Logout'),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.red,
          side: const BorderSide(color: Colors.red),
          minimumSize: const Size(double.infinity, 40),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.home,
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
