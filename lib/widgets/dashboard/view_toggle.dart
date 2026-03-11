import 'package:flutter/material.dart';
import '../../../core/constants/app_enums.dart';

class ViewToggle extends StatelessWidget {
  final ViewType currentView;
  final Function(ViewType) onChanged;

  const ViewToggle({
    Key? key,
    required this.currentView,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildButton('Lab', ViewType.lab),
          _buildButton('Lecture', ViewType.lecture),
        ],
      ),
    );
  }

  Widget _buildButton(String label, ViewType value) {
    final isSelected = currentView == value;

    return GestureDetector(
      onTap: () => onChanged(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.blue : Colors.grey.shade700,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
