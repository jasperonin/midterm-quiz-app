import 'package:flutter/material.dart';
import '../../../core/constants/app_enums.dart';

class TimeRangeSelector extends StatelessWidget {
  final TimeRange selectedRange;
  final Function(TimeRange) onChanged;

  const TimeRangeSelector({
    Key? key,
    required this.selectedRange,
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
          _buildButton('Today', TimeRange.today),
          _buildButton('Week', TimeRange.weekly),
          _buildButton('Month', TimeRange.monthly),
        ],
      ),
    );
  }

  Widget _buildButton(String label, TimeRange range) {
    final isSelected = selectedRange == range;

    return GestureDetector(
      onTap: () => onChanged(range),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey.shade700,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
