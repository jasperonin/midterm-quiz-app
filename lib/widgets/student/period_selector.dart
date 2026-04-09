// lib/widgets/student/period_selector.dart
import 'package:flutter/material.dart';

class PeriodSelector extends StatelessWidget {
  final String selectedPeriod;
  final Function(String) onPeriodChanged;

  const PeriodSelector({
    super.key,
    required this.selectedPeriod,
    required this.onPeriodChanged,
  });

  @override
  Widget build(BuildContext context) {
    final activeStyle = TextStyle(
      fontWeight: FontWeight.bold,
      color: Colors.teal.shade800,
    );
    final inactiveStyle = TextStyle(
      fontWeight: FontWeight.normal,
      color: Colors.grey.shade600,
    );

    return Row(
      children: [
        const Text(
          '📊 Assessment Period',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const Spacer(),
        TextButton(
          onPressed: () => onPeriodChanged('midterm'),
          child: Text(
            'Midterm',
            style: selectedPeriod == 'midterm' ? activeStyle : inactiveStyle,
          ),
        ),
        const SizedBox(width: 12),
        TextButton(
          onPressed: () => onPeriodChanged('finals'),
          child: Text(
            'Finals',
            style: selectedPeriod == 'finals' ? activeStyle : inactiveStyle,
          ),
        ),
      ],
    );
  }
}
