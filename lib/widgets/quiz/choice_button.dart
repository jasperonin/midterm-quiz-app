// lib/widgets/quiz/choice_button.dart
import 'package:flutter/material.dart';

class ChoiceButton extends StatelessWidget {
  final String text;
  final int index;
  final VoidCallback onTap;

  const ChoiceButton({
    Key? key,
    required this.text,
    required this.index,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ListTile(
        title: Text(text, style: const TextStyle(fontSize: 16)),
        leading: CircleAvatar(
          backgroundColor: Colors.blue.shade100,
          child: Text(
            String.fromCharCode(65 + index),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade800,
            ),
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}
