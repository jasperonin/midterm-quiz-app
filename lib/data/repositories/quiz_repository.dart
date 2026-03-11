// lib/data/repositories/quiz_repository.dart
import 'package:app/models/quiz_data.dart' show QuizData;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'base_repository.dart';

class QuizRepository extends BaseRepository<QuizData> {
  @override
  String get collectionName => 'quizzes';

  @override
  Future<QuizData?> get(String id) async {
    try {
      final doc = await collection.doc(id).get();
      if (!doc.exists) return null;
      return QuizData.fromFirestore(doc);
    } catch (e) {
      print('Error getting quiz: $e');
      return null;
    }
  }

  @override
  Future<List<QuizData>> getAll({
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
      return snapshot.docs.map((doc) => QuizData.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error getting quizzes: $e');
      return [];
    }
  }

  @override
  Future<String> create(QuizData item) async {
    try {
      final doc = await collection.add(item.toFirestore());
      return doc.id;
    } catch (e) {
      print('Error creating quiz: $e');
      rethrow;
    }
  }

  @override
  Future<void> update(String id, QuizData item) async {
    try {
      await collection.doc(id).update(item.toFirestore());
    } catch (e) {
      print('Error updating quiz: $e');
      rethrow;
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      await collection.doc(id).delete();
    } catch (e) {
      print('Error deleting quiz: $e');
      rethrow;
    }
  }

  @override
  Stream<QuizData?> watch(String id) {
    return collection.doc(id).snapshots().map((doc) {
      if (!doc.exists) return null;
      return QuizData.fromFirestore(doc);
    });
  }

  @override
  Stream<List<QuizData>> watchAll({
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
      return snapshot.docs.map((doc) => QuizData.fromFirestore(doc)).toList();
    });
  }

  // Quiz-specific methods
  Future<List<QuizData>> getQuizzesByCourse(String courseId) async {
    return getAll(
      where: [WhereClause(field: 'courseId', isEqualTo: courseId)],
      orderBy: 'createdAt',
      descending: true,
    );
  }

  Future<Map<String, dynamic>> getQuizResults(String quizId) async {
    try {
      final resultsSnapshot = await firestore
          .collection('quizResults')
          .where('quizId', isEqualTo: quizId)
          .get();

      if (resultsSnapshot.docs.isEmpty) {
        return {
          'totalSubmissions': 0,
          'averageScore': 0.0,
          'passingRate': 0.0,
          'scoreDistribution': {},
        };
      }

      double totalScore = 0;
      int passed = 0;
      final Map<String, int> distribution = {};

      for (var doc in resultsSnapshot.docs) {
        final data = doc.data();
        final score = (data['score'] ?? 0).toDouble();
        totalScore += score;

        // Check if passed (assuming passing score is 60)
        if (score >= 60) passed++;

        // Build distribution
        final range = _getScoreRange(score);
        distribution[range] = (distribution[range] ?? 0) + 1;
      }

      final averageScore = totalScore / resultsSnapshot.docs.length;
      final passingRate = (passed / resultsSnapshot.docs.length) * 100;

      return {
        'totalSubmissions': resultsSnapshot.docs.length,
        'averageScore': averageScore,
        'passingRate': passingRate,
        'scoreDistribution': distribution,
      };
    } catch (e) {
      print('Error getting quiz results: $e');
      return {};
    }
  }

  String _getScoreRange(double score) {
    if (score >= 90) return '90-100';
    if (score >= 80) return '80-89';
    if (score >= 70) return '70-79';
    if (score >= 60) return '60-69';
    if (score >= 50) return '50-59';
    return '0-49';
  }
}
