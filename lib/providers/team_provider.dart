import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/repositories/team_repository.dart';
import '../models/team.dart';

// Team repository provider
final teamRepositoryProvider = Provider<TeamRepository>((ref) {
  return TeamRepository();
});

// Teams by department provider
final teamsByDepartmentProvider = StreamProvider.family<List<Team>, String>((ref, departmentId) {
  final repository = ref.watch(teamRepositoryProvider);
  return repository.watchByDepartment(departmentId);
});

// Teams by member provider
final teamsByMemberProvider = StreamProvider.family<List<Team>, String>((ref, userId) {
  final repository = ref.watch(teamRepositoryProvider);
  return repository.watchByMember(userId);
});

// Teams by leader provider
final teamsByLeaderProvider = StreamProvider.family<List<Team>, String>((ref, userId) {
  final repository = ref.watch(teamRepositoryProvider);
  return repository.watchByLeader(userId);
});

// Single team provider
final teamProvider = StreamProvider.family<Team?, String>((ref, teamId) {
  final repository = ref.watch(teamRepositoryProvider);
  return repository.watchById(teamId);
});

// Team actions provider
final teamActionsProvider = Provider<TeamActions>((ref) {
  final repository = ref.watch(teamRepositoryProvider);
  return TeamActions(repository);
});

class TeamActions {
  final TeamRepository _repository;

  TeamActions(this._repository);

  Future<String> createTeam(Team team) async {
    return await _repository.create(team);
  }

  Future<void> updateTeam(String id, Team team) async {
    await _repository.update(id, team);
  }

  Future<void> deleteTeam(String id) async {
    await _repository.delete(id);
  }

  Future<void> addMember(String teamId, String userId) async {
    await _repository.addMember(teamId, userId);
  }

  Future<void> removeMember(String teamId, String userId) async {
    await _repository.removeMember(teamId, userId);
  }

  Future<List<Team>> getTeamsByDepartment(String departmentId) async {
    return await _repository.getByDepartment(departmentId);
  }

  Future<List<Team>> getTeamsByMember(String userId) async {
    return await _repository.getByMember(userId);
  }

  Future<List<Team>> getTeamsByLeader(String userId) async {
    return await _repository.getByLeader(userId);
  }
}
