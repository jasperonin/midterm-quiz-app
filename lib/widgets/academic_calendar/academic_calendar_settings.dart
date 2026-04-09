// lib/widgets/academic_calendar/academic_calendar_settings.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'date_range_picker.dart';

class AcademicCalendarSettings extends StatefulWidget {
  const AcademicCalendarSettings({super.key});

  @override
  State<AcademicCalendarSettings> createState() =>
      _AcademicCalendarSettingsState();
}

class _AcademicCalendarSettingsState extends State<AcademicCalendarSettings> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = true;
  bool _autoAssign = true;
  Map<String, dynamic>? _terms;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final doc = await _firestore
          .collection('settings')
          .doc('academicCalendar')
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          _terms = data['terms'];
          _autoAssign = data['autoAssign'] ?? true;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _saveSettings() async {
    setState(() => _isLoading = true);

    try {
      await _firestore.collection('settings').doc('academicCalendar').update({
        'terms': _terms,
        'autoAssign': _autoAssign,
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Settings saved successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(_errorMessage!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadSettings,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final midterm = _terms?['midterm'];
    final finals = _terms?['finals'];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Academic Calendar Settings',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Configure the date ranges for Midterm and Finals periods',
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 32),

          // Midterm Range
          DateRangePicker(
            label: 'Midterm Period',
            startDate: (midterm['startDate'] as Timestamp).toDate(),
            endDate: (midterm['endDate'] as Timestamp).toDate(),
            onRangeSelected: (range) {
              setState(() {
                _terms!['midterm']['startDate'] = Timestamp.fromDate(
                  range.start,
                );
                _terms!['midterm']['endDate'] = Timestamp.fromDate(range.end);
              });
            },
          ),

          const SizedBox(height: 24),

          // Finals Range
          DateRangePicker(
            label: 'Finals Period',
            startDate: (finals['startDate'] as Timestamp).toDate(),
            endDate: (finals['endDate'] as Timestamp).toDate(),
            onRangeSelected: (range) {
              setState(() {
                _terms!['finals']['startDate'] = Timestamp.fromDate(
                  range.start,
                );
                _terms!['finals']['endDate'] = Timestamp.fromDate(range.end);
              });
            },
          ),

          const SizedBox(height: 24),

          // Auto-assign toggle
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.shade200),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Auto-assign Period',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Automatically assign period based on completion date',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: _autoAssign,
                    onChanged: (value) {
                      setState(() => _autoAssign = value);
                    },
                    activeColor: Colors.teal,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Save button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _saveSettings,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Save Settings',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
