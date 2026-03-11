import 'package:flutter/material.dart';

class SettingsNotificationsScreen extends StatefulWidget {
  const SettingsNotificationsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsNotificationsScreen> createState() => _SettingsNotificationsScreenState();
}

class _SettingsNotificationsScreenState extends State<SettingsNotificationsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Settings'),
      ),
      body: const Center(
        child: Text('Notification Settings Screen'),
      ),
    );
  }
}