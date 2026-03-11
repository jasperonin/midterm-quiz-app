// lib/data/repositories/course_repository.dart
import 'package:app/models/course_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'base_repository.dart';

class CourseRepository extends BaseRepository<CourseModel> {
  @override
  String get collectionName => 'courses';

  @override
  Future<CourseModel?> get(String id) async {
    try {
      final doc = await collection.doc(id).get();
      if (!doc.exists) return null;
      return CourseModel.fromFirestore(doc);
    } catch (e) {
      print('Error getting course: $e');
      return null;
    }
  }

  @override
  Future<List<CourseModel>> getAll({
    List<WhereClause>? where,
    String? orderBy,
    bool descending = false,
    int? limit,
    DocumentSnapshot? startAfter,
  }) async {
    try {
      Query query = collection;

      // Apply where clauses
      if (where != null) {
        for (final clause in where) {
          query = clause.apply(query);
        }
      }

      // Apply ordering
      if (orderBy != null) {
        query = query.orderBy(orderBy, descending: descending);
      }

      // Apply pagination
      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      if (limit != null) {
        query = query.limit(limit);
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => CourseModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error getting courses: $e');
      return [];
    }
  }

  @override
  Future<String> create(CourseModel item) async {
    try {
      final doc = await collection.add(item.toFirestore());
      return doc.id;
    } catch (e) {
      print('Error creating course: $e');
      rethrow;
    }
  }

  @override
  Future<void> update(String id, CourseModel item) async {
    try {
      await collection.doc(id).update(item.toFirestore());
    } catch (e) {
      print('Error updating course: $e');
      rethrow;
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      await collection.doc(id).delete();
    } catch (e) {
      print('Error deleting course: $e');
      rethrow;
    }
  }

  @override
  Stream<CourseModel?> watch(String id) {
    return collection.doc(id).snapshots().map((doc) {
      if (!doc.exists) return null;
      return CourseModel.fromFirestore(doc);
    });
  }

  @override
  Stream<List<CourseModel>> watchAll({
    List<WhereClause>? where,
    String? orderBy,
    bool descending = false,
    int? limit,
  }) {
    Query query = collection;

    // Apply where clauses
    if (where != null) {
      for (final clause in where) {
        query = clause.apply(query);
      }
    }

    // Apply ordering
    if (orderBy != null) {
      query = query.orderBy(orderBy, descending: descending);
    }

    if (limit != null) {
      query = query.limit(limit);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => CourseModel.fromFirestore(doc))
          .toList();
    });
  }

  // Course-specific methods
  Future<List<CourseModel>> getCoursesByTeacher(String teacherId) async {
    return getAll(
      where: [WhereClause(field: 'teacherId', isEqualTo: teacherId)],
      orderBy: 'createdAt',
      descending: true,
    );
  }

  Future<Map<String, dynamic>> getCourseStats(String courseId) async {
    try {
      final course = await get(courseId);
      if (course == null) return {};

      // Get students count
      final studentsCount = course.studentIds.length;

      // Get quizzes count
      final quizzesCount = course.quizIds.length;

      // Get average performance (would need to query quizResults)

      return {
        'totalStudents': studentsCount,
        'totalQuizzes': quizzesCount,
        'completionRate': 0.0, // Calculate from quiz results
        'averageScore': 0.0, // Calculate from quiz results
      };
    } catch (e) {
      print('Error getting course stats: $e');
      return {};
    }
  }
}
