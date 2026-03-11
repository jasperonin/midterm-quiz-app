import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  final String? teacherId;

  const ProfileScreen({Key? key, this.teacherId}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Center(
        child: Text('Profile Screen - Teacher ID: ${widget.teacherId}'),
      ),
    );
  }
}
