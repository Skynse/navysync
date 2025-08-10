import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/team.dart';
import 'base_repository.dart';

class TeamRepository extends BaseRepository<Team> {
  TeamRepository() : super('teams');

  @override
  Team fromFirestore(DocumentSnapshot doc) => Team.fromFirestore(doc);

  @override
  Map<String, dynamic> toFirestore(Team item) => item.toFirestore();

  // Get teams by department
  Future<List<Team>> getByDepartment(String departmentId, {int? limit}) async {
    return getAll(
      query: collection
          .where('departmentId', isEqualTo: departmentId),
      limit: limit,
    );
  }

  // Get teams where user is a member
  Future<List<Team>> getByMember(String userId, {int? limit}) async {
    return getAll(
      query: collection
          .where('members', arrayContains: userId),

      limit: limit,
    );
  }

  // Get teams where user is the leader
  Future<List<Team>> getByLeader(String userId, {int? limit}) async {
    return getAll(
      query: collection
          .where('teamLeaderId', isEqualTo: userId),
      limit: limit,
    );
  }

  // Add member to team
  Future<void> addMember(String teamId, String userId) async {
    try {
      await collection.doc(teamId).update({
        'members': FieldValue.arrayUnion([userId]),
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('Failed to add member to team: $e');
    }
  }

  // Remove member from team
  Future<void> removeMember(String teamId, String userId) async {
    try {
      await collection.doc(teamId).update({
        'members': FieldValue.arrayRemove([userId]),
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('Failed to remove member from team: $e');
    }
  }

  // Watch teams by department
  Stream<List<Team>> watchByDepartment(String departmentId) {
    return watchAll(
      query: collection
          .where('departmentId', isEqualTo: departmentId)
  
    );
  }

  // Watch teams by member
  Stream<List<Team>> watchByMember(String userId) {
    return watchAll(
      query: collection
          .where('members', arrayContains: userId)
  
    );
  }

  // Watch teams by leader
  Stream<List<Team>> watchByLeader(String userId) {
    return watchAll(
      query: collection
          .where('teamLeaderId', isEqualTo: userId),
    );
  }
}
