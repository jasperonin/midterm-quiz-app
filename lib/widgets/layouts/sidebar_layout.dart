// lib/widgets/layouts/sidebar_layout.dart
import 'package:app/utils/navigation_helper.dart';
import 'package:flutter/material.dart';

class SidebarLayout extends StatelessWidget {
  final String teacherId;
  final String teacherName;
  final String currentRoute;
  final Widget child;

  const SidebarLayout({
    super.key,
    required this.teacherId,
    required this.teacherName,
    required this.currentRoute,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Sidebar
        Container(
          width: 280,
          color: Colors.teal.shade700,
          child: Column(
            children: [
              const SizedBox(height: 40),
              // Teacher avatar
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.person,
                  size: 40,
                  color: Colors.teal.shade700,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                teacherName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Teacher ID: $teacherId',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
              const SizedBox(height: 32),
              // Menu items
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildMenuItem(
                        Icons.dashboard,
                        'Dashboard',
                        '/dashboard',
                        onTap: () => NavigationHelper.goToDashboard(
                          context,
                          teacherId: teacherId,
                          teacherName: teacherName,
                        ),
                      ),
                      _buildMenuItem(
                        Icons.people,
                        'Students',
                        '/students',
                        onTap: () => NavigationHelper.goToStudents(context),
                      ),

                      _buildMenuItem(
                        Icons.bar_chart,
                        'Reports',
                        '/reports',
                        onTap: () => NavigationHelper.goToAnalytics(context),
                      ),
                      _buildMenuItem(
                        Icons.calendar_today,
                        'Academic Calendar',
                        '/academic-calendar',
                        onTap: () =>
                            NavigationHelper.goToAcademicCalendar(context),
                      ),
                      const Divider(
                        color: Colors.white54,
                        indent: 16,
                        endIndent: 16,
                      ),
                      _buildMenuItem(
                        Icons.settings,
                        'Settings',
                        '/settings',
                        onTap: () => NavigationHelper.goToSettings(context),
                      ),
                      _buildMenuItem(
                        Icons.person,
                        'Profile',
                        '/profile',
                        onTap: () =>
                            NavigationHelper.goToProfile(context, teacherId),
                      ),
                      _buildMenuItem(
                        Icons.logout,
                        'Logout',
                        '/logout',
                        onTap: () => _handleLogout(context),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
        // Main content
        Expanded(child: child),
      ],
    );
  }

  Widget _buildMenuItem(
    IconData icon,
    String label,
    String route, {
    required VoidCallback onTap,
  }) {
    final isSelected = currentRoute == route;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected ? Colors.white.withOpacity(0.2) : null,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.white),
        title: Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 14),
        ),
        onTap: onTap,
      ),
    );
  }

  void _handleLogout(BuildContext context) {
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
              // Navigate to login screen
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
