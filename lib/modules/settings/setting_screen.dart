import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile'),
            subtitle: const Text('Manage your profile information'),
            onTap: () {
              // Navigate to profile
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('General'),
            subtitle: const Text('App preferences and settings'),
            onTap: () {
              // Navigate to general settings
            },
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Notifications'),
            subtitle: const Text('Configure notification preferences'),
            onTap: () {
              // Navigate to notifications
            },
          ),
          ListTile(
            leading: const Icon(Icons.security),
            title: const Text('Security'),
            subtitle: const Text('Security and privacy settings'),
            onTap: () {
              // Navigate to security
            },
          ),
        ],
      ),
    );
  }
}
