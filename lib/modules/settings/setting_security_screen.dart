import 'package:flutter/material.dart';

class SettingsSecurityScreen extends StatefulWidget {
  const SettingsSecurityScreen({Key? key}) : super(key: key);

  @override
  State<SettingsSecurityScreen> createState() => _SettingsSecurityScreenState();
}

class _SettingsSecurityScreenState extends State<SettingsSecurityScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Security Settings')),
      body: const Center(child: Text('Security Settings Screen')),
    );
  }
}
