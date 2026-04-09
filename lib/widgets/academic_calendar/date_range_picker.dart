// lib/widgets/academic_calendar/date_range_picker.dart
import 'dart:ui';
import 'package:flutter/material.dart';

class DateRangePicker extends StatelessWidget {
  final String label;
  final DateTime startDate;
  final DateTime endDate;
  final Function(DateTimeRange) onRangeSelected;

  const DateRangePicker({
    super.key,
    required this.label,
    required this.startDate,
    required this.endDate,
    required this.onRangeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.teal.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.calendar_today,
                    size: 20,
                    color: Colors.teal.shade700,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Display current range
            InkWell(
              onTap: () => _showDateRangePicker(context),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.date_range,
                      color: Colors.teal.shade700,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '${_formatDate(startDate)} - ${_formatDate(endDate)}',
                        style: const TextStyle(fontSize: 15),
                      ),
                    ),
                    Icon(Icons.edit_calendar, color: Colors.grey.shade400),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showDateRangePicker(BuildContext context) async {
    try {
      // Wrap the picker to avoid display feature issues
      final DateTimeRange? picked = await showDialog<DateTimeRange>(
        context: context,
        builder: (dialogContext) => MediaQuery(
          // Remove display features that cause the error
          data: MediaQuery.of(
            context,
          ).copyWith(displayFeatures: const <DisplayFeature>[]),
          child: Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(
                primary: Colors.teal,
                onPrimary: Colors.white,
                surface: Colors.teal,
                onSurface: Colors.teal,
              ),
            ),
            child: DateRangePickerDialog(
              initialDateRange: DateTimeRange(start: startDate, end: endDate),
              firstDate: DateTime(2020),
              lastDate: DateTime(2030),
              helpText: label,
              saveText: 'Save',
              cancelText: 'Cancel',
            ),
          ),
        ),
      );

      if (picked != null) {
        onRangeSelected(picked);
      }
    } catch (e) {
      print('Error showing date picker: $e');
      // Fallback to simple dialog if there's an error
      _showFallbackDatePicker(context);
    }
  }

  // Fallback for when the main picker fails
  void _showFallbackDatePicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(label),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Start: ${_formatDate(startDate)}'),
            Text('End: ${_formatDate(endDate)}'),
            const SizedBox(height: 16),
            const Text('Use the calendar buttons to change dates'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }
}
