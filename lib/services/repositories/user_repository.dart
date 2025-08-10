import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/user.dart';
import 'base_repository.dart';

class UserRepository extends BaseRepository<NavySyncUser> {
  UserRepository() : super('users');

  @override
  NavySyncUser fromFirestore(DocumentSnapshot doc) => NavySyncUser.fromFirestore(doc);

  @override
  Map<String, dynamic> toFirestore(NavySyncUser item) => item.toFirestore();

  // Get users by department
  Future<List<NavySyncUser>> getByDepartment(String departmentId, {int? limit}) async {
    return getAll(
      query: collection
          .where('departmentId', isEqualTo: departmentId)
          .where('isActive', isEqualTo: true),
      limit: limit,
    );
  }

  // Get users by team
  Future<List<NavySyncUser>> getByTeam(String teamId, {int? limit}) async {
    return getAll(
      query: collection
          .where('teamIds', arrayContains: teamId)
          .where('isActive', isEqualTo: true),
      limit: limit,
    );
  }

  // Get users by role
  Future<List<NavySyncUser>> getByRole(String role, {int? limit}) async {
    return getAll(
      query: collection
          .where('roles', arrayContains: role)
          .where('isActive', isEqualTo: true),
      limit: limit,
    );
  }

  // Get user by email
  Future<NavySyncUser?> getByEmail(String email) async {
    try {
      final querySnapshot = await collection
          .where('email', isEqualTo: email)
          .limit(1)
          .get();
      
      if (querySnapshot.docs.isEmpty) return null;
      return fromFirestore(querySnapshot.docs.first);
    } catch (e) {
      throw Exception('Failed to get user by email: $e');
    }
  }

  // Add team to user
  Future<void> addTeam(String userId, String teamId) async {
    try {
      await collection.doc(userId).update({
        'teamIds': FieldValue.arrayUnion([teamId]),
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('Failed to add team to user: $e');
    }
  }

  // Remove team from user
  Future<void> removeTeam(String userId, String teamId) async {
    try {
      await collection.doc(userId).update({
        'teamIds': FieldValue.arrayRemove([teamId]),
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('Failed to remove team from user: $e');
    }
  }

  // Update user roles
  Future<void> updateRoles(String userId, List<String> roles) async {
    try {
      await collection.doc(userId).update({
        'roles': roles,
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('Failed to update user roles: $e');
    }
  }

  // Watch users by department
  Stream<List<NavySyncUser>> watchByDepartment(String departmentId) {
    return watchAll(
      query: collection
          .where('departmentId', isEqualTo: departmentId)
          .where('isActive', isEqualTo: true),
    );
  }

  // Watch users by team
  Stream<List<NavySyncUser>> watchByTeam(String teamId) {
    return watchAll(
      query: collection
          .where('teamIds', arrayContains: teamId)
          .where('isActive', isEqualTo: true),
    );
  }
}
