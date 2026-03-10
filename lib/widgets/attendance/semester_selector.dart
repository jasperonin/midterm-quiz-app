// lib/widgets/attendance/semester_selector.dart
import 'package:flutter/material.dart';

class SemesterSelector extends StatelessWidget {
  final List<String> semesters;
  final String selectedSemester;
  final ValueChanged<String> onSemesterChanged;
  final List<String> sections;
  final String selectedSection;
  final ValueChanged<String> onSectionChanged;

  const SemesterSelector({
    Key? key,
    required this.semesters,
    required this.selectedSemester,
    required this.onSemesterChanged,
    required this.sections,
    required this.selectedSection,
    required this.onSectionChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Term selection chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: semesters.map((semester) {
                final isSelected = semester == selectedSemester;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(semester),
                    selected: isSelected,
                    onSelected: (_) => onSemesterChanged(semester),
                    backgroundColor: Colors.grey.shade100,
                    selectedColor: Colors.teal.shade100,
                    checkmarkColor: Colors.teal,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.teal : Colors.black87,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 12),

          // Section dropdown
          Row(
            children: [
              const Icon(Icons.class_, size: 20, color: Colors.grey),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: selectedSection,
                  decoration: InputDecoration(
                    labelText: 'Section',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  items: sections.map((section) {
                    return DropdownMenuItem(
                      value: section,
                      child: Text(section),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      onSectionChanged(value);
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
