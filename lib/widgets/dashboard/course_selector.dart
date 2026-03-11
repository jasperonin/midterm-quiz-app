// lib/modules/dashboard/widgets/course_selector.dart
import 'package:app/models/course_model.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CourseSelector extends StatelessWidget {
  final String teacherId;
  final String? selectedCourseId;
  final Function(String?) onChanged;

  const CourseSelector({
    Key? key,
    required this.teacherId,
    required this.selectedCourseId,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('courses')
            .where('teacherId', isEqualTo: teacherId)
            .snapshots()
            .handleError((error) {
              debugPrint('Course error $error');
              return [];
            }),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            );
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text('Error loading courses'));
          }

          final courses = snapshot.data!.docs
              .map((doc) => CourseModel.fromFirestore(doc))
              .toList();

          if (courses.isEmpty) {
            return const Center(child: Text('No courses available'));
          }

          return DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedCourseId ?? courses.first.id,
              icon: const Icon(Icons.arrow_drop_down),
              isExpanded: true,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              onChanged: (value) => onChanged(value),
              items: [
                const DropdownMenuItem(value: null, child: Text('All Courses')),
                ...courses.map((course) {
                  return DropdownMenuItem(
                    value: course.id,
                    child: Text(
                      '${course.code} - ${course.name}',
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }),
              ],
            ),
          );
        },
      ),
    );
  }
}
