import 'package:cloud_firestore/cloud_firestore.dart';

abstract class BaseRepository<T> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collectionName;

  BaseRepository(this.collectionName);

  CollectionReference get collection => _firestore.collection(collectionName);

  // Abstract methods to be implemented by subclasses
  T fromFirestore(DocumentSnapshot doc);
  Map<String, dynamic> toFirestore(T item);

  // Generic CRUD operations
  Future<String> create(T item) async {
    try {
      final docRef = await collection.add(toFirestore(item));
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create ${T.toString()}: $e');
    }
  }

  Future<T?> getById(String id) async {
    try {
      final doc = await collection.doc(id).get();
      if (!doc.exists) return null;
      return fromFirestore(doc);
    } catch (e) {
      throw Exception('Failed to get ${T.toString()}: $e');
    }
  }

  Future<List<T>> getAll({
    Query<Object?>? query,
    int? limit,
  }) async {
    try {
      Query<Object?> baseQuery = query ?? collection;
      if (limit != null) {
        baseQuery = baseQuery.limit(limit);
      }
      
      final snapshot = await baseQuery.get();
      return snapshot.docs.map((doc) => fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to get all ${T.toString()}: $e');
    }
  }

  Future<void> update(String id, T item) async {
    try {
      await collection.doc(id).update(toFirestore(item));
    } catch (e) {
      throw Exception('Failed to update ${T.toString()}: $e');
    }
  }

  Future<void> delete(String id) async {
    try {
      await collection.doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete ${T.toString()}: $e');
    }
  }

  Stream<List<T>> watchAll({Query<Object?>? query}) {
    Query<Object?> baseQuery = query ?? collection;
    return baseQuery.snapshots().map(
      (snapshot) => snapshot.docs.map((doc) => fromFirestore(doc)).toList(),
    );
  }

  Stream<T?> watchById(String id) {
    return collection.doc(id).snapshots().map(
      (doc) => doc.exists ? fromFirestore(doc) : null,
    );
  }
}
