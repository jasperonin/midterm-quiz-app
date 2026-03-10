// lib/widgets/quiz/choice_button.dart
import 'package:flutter/material.dart';

class ChoiceButton extends StatelessWidget {
  final String text;
  final int index;
  final bool isSelected;
  final Color? customColor;
  final VoidCallback? onTap;

  const ChoiceButton({
    Key? key,
    required this.text,
    required this.index,
    this.isSelected = false,
    this.customColor,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final letter = String.fromCharCode(65 + index); // A, B, C, D

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color:
            customColor ?? (isSelected ? Colors.blue.shade100 : Colors.white),
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(
                color: isSelected ? Colors.blue : Colors.grey.shade300,
                width: isSelected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.blue : Colors.grey.shade200,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      letter,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    text,
                    style: TextStyle(
                      fontSize: 16,
                      color: onTap == null ? Colors.grey : Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
