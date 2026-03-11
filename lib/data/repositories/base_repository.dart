// lib/data/repositories/base_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';

abstract class BaseRepository<T> {
  final FirebaseFirestore firestore;

  BaseRepository({FirebaseFirestore? firestore})
    : firestore = firestore ?? FirebaseFirestore.instance;

  String get collectionName;

  CollectionReference get collection => firestore.collection(collectionName);

  Future<T?> get(String id);

  Future<List<T>> getAll({
    List<WhereClause>? where,
    String? orderBy,
    bool descending = false,
    int? limit,
    DocumentSnapshot? startAfter,
  });

  Future<String> create(T item);

  Future<void> update(String id, T item);

  Future<void> delete(String id);

  Stream<T?> watch(String id);

  Stream<List<T>> watchAll({
    List<WhereClause>? where,
    String? orderBy,
    bool descending = false,
    int? limit,
  });
}

class WhereClause {
  final String field;
  final dynamic isEqualTo;
  final dynamic isLessThan;
  final dynamic isGreaterThan;
  final dynamic isLessThanOrEqualTo;
  final dynamic isGreaterThanOrEqualTo;
  final dynamic arrayContains;
  final List<dynamic>? whereIn;
  final bool? isNull;

  WhereClause({
    required this.field,
    this.isEqualTo,
    this.isLessThan,
    this.isGreaterThan,
    this.isLessThanOrEqualTo,
    this.isGreaterThanOrEqualTo,
    this.arrayContains,
    this.whereIn,
    this.isNull,
  });

  Query apply(Query query) {
    if (isEqualTo != null) return query.where(field, isEqualTo: isEqualTo);
    if (isLessThan != null) return query.where(field, isLessThan: isLessThan);
    if (isGreaterThan != null)
      return query.where(field, isGreaterThan: isGreaterThan);
    if (isLessThanOrEqualTo != null) {
      return query.where(field, isLessThanOrEqualTo: isLessThanOrEqualTo);
    }
    if (isGreaterThanOrEqualTo != null) {
      return query.where(field, isGreaterThanOrEqualTo: isGreaterThanOrEqualTo);
    }
    if (arrayContains != null) {
      return query.where(field, arrayContains: arrayContains);
    }
    if (whereIn != null) return query.where(field, whereIn: whereIn);
    if (isNull != null) return query.where(field, isNull: isNull);

    return query;
  }
}
