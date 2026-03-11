import 'package:flutter/material.dart';

class SettingsGeneralScreen extends StatefulWidget {
  const SettingsGeneralScreen({Key? key}) : super(key: key);

  @override
  State<SettingsGeneralScreen> createState() => _SettingsGeneralScreenState();
}

class _SettingsGeneralScreenState extends State<SettingsGeneralScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('General Settings')),
      body: const Center(child: Text('General Settings Screen')),
    );
  }
}
