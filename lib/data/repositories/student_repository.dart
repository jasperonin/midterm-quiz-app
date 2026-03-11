// lib/data/repositories/student_repository.dart
import 'package:app/models/student_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'base_repository.dart';

class StudentRepository extends BaseRepository<StudentModel> {
  @override
  String get collectionName => 'users'; // Using 'users' collection

  @override
  Future<StudentModel?> get(String id) async {
    try {
      final doc = await collection.doc(id).get();
      if (!doc.exists) return null;
      return StudentModel.fromFirestore(doc);
    } catch (e) {
      print('Error getting student: $e');
      return null;
    }
  }

  @override
  Future<List<StudentModel>> getAll({
    List<WhereClause>? where,
    String? orderBy,
    bool descending = false,
    int? limit,
    DocumentSnapshot? startAfter,
  }) async {
    try {
      Query query = collection;
      
      if (where != null) {
        for (final clause in where) {
          query = clause.apply(query);
        }
      }
      
      if (orderBy != null) {
        query = query.orderBy(orderBy, descending: descending);
      }
      
      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }
      
      if (limit != null) {
        query = query.limit(limit);
      }
      
      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => StudentModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error getting students: $e');
      return [];
    }
  }

  @override
  Future<String> create(StudentModel item) async {
    try {
      final doc = await collection.add(item.toFirestore());
      return doc.id;
    } catch (e) {
      print('Error creating student: $e');
      rethrow;
    }
  }

  @override
  Future<void> update(String id, StudentModel item) async {
    try {
      await collection.doc(id).update(item.toFirestore());
    } catch (e) {
      print('Error updating student: $e');
      rethrow;
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      await collection.doc(id).delete();
    } catch (e) {
      print('Error deleting student: $e');
      rethrow;
    }
  }

  @override
  Stream<StudentModel?> watch(String id) {
    return collection.doc(id).snapshots().map((doc) {
      if (!doc.exists) return null;
      return StudentModel.fromFirestore(doc);
    });
  }

  @override
  Stream<List<StudentModel>> watchAll({
    List<WhereClause>? where,
    String? orderBy,
    bool descending = false,
    int? limit,
  }) {
    Query query = collection;
    
    if (where != null) {
      for (final clause in where) {
        query = clause.apply(query);
      }
    }
    
    if (orderBy != null) {
      query = query.orderBy(orderBy, descending: descending);
    }
    
    if (limit != null) {
      query = query.limit(limit);
    }
    
    return query.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => StudentModel.fromFirestore(doc))
          .toList();
    });
  }

  // Student-specific methods
  Future<List<StudentModel>> getStudentsByCourse(String courseId) async {
    return getAll(
      where: [WhereClause(field: 'enrolledCourses', arrayContains: courseId)],
      orderBy: 'last_name',
    );
  }

  Future<List<StudentModel>> searchStudents(String query) async {
    // Note: Firestore doesn't support full-text search
    // This is a simple implementation - consider using Algolia or similar for production
    try {
      final snapshot = await collection
          .orderBy('last_name')
          .startAt([query])
          .endAt([query + '\uf8ff'])
          .limit(20)
          .get();
      
      return snapshot.docs
          .map((doc) => StudentModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error searching students: $e');
      return [];
    }
  }

  Future<void> bulkImport(List<StudentModel> students) async {
    final batch = firestore.batch();
    
    for (final student in students) {
      final docRef = collection.doc();
      batch.set(docRef, student.toFirestore());
    }
    
    await batch.commit();
  }

  Future<Map<String, dynamic>> getStudentPerformance(String studentId) async {
    try {
      // Get all quiz results for this student
      final resultsSnapshot = await firestore
          .collection('quizResults')
          .where('studentId', isEqualTo: studentId)
          .get();
      
      if (resultsSnapshot.docs.isEmpty) {
        return {
          'averageScore': 0.0,
          'quizzesTaken': 0,
          'totalTimeSpent': 0,
          'performanceByCourse': {},
        };
      }

      double totalScore = 0;
      int totalTimeSpent = 0;
      final Map<String, List<double>> courseScores = {};

      for (var doc in resultsSnapshot.docs) {
        final data = doc.data();
        final score = (data['score'] ?? 0).toDouble();
        final courseId = data['courseId'] ?? 'unknown';
        final timeSpent = data['timeSpent'] ?? 0;

        totalScore += score;
        totalTimeSpent += timeSpent as int;

        if (!courseScores.containsKey(courseId)) {
          courseScores[courseId] = [];
        }
        courseScores[courseId]!.add(score);
      }

      final averageScore = totalScore / resultsSnapshot.docs.length;
      
      // Calculate averages per course
      final Map<String, double> courseAverages = {};
      courseScores.forEach((courseId, scores) {
        final avg = scores.reduce((a, b) => a + b) / scores.length;
        courseAverages[courseId] = avg;
      });

      return {
        'averageScore': averageScore,
        'quizzesTaken': resultsSnapshot.docs.length,
        'totalTimeSpent': totalTimeSpent,
        'courseAverages': courseAverages,
      };
    } catch (e) {
      print('Error getting student performance: $e');
      return {};
    }
  }
}