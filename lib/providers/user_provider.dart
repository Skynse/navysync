import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user.dart';
import '../services/repositories/user_repository.dart';

// User repository provider
final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository();
});

// Get all active users provider
final allActiveUsersProvider = FutureProvider<List<NavySyncUser>>((ref) async {
  final repository = ref.read(userRepositoryProvider);
  return await repository.getAll(
    query: repository.collection.where('isActive', isEqualTo: true).limit(100),
  );
});

// Search users provider
final searchUsersProvider = FutureProvider.family<List<NavySyncUser>, String>((ref, query) async {
  if (query.trim().isEmpty || query.trim().length < 2) return [];
  
  final repository = ref.read(userRepositoryProvider);
  return await repository.searchUsers(query);
});

// Get users by department provider
final usersByDepartmentProvider = FutureProvider.family<List<NavySyncUser>, String>((ref, departmentId) async {
  final repository = ref.read(userRepositoryProvider);
  return await repository.getByDepartment(departmentId);
});

// Get users by team provider
final usersByTeamProvider = FutureProvider.family<List<NavySyncUser>, String>((ref, teamId) async {
  final repository = ref.read(userRepositoryProvider);
  return await repository.getByTeam(teamId);
});

// Create test users provider
final createTestUsersProvider = FutureProvider<void>((ref) async {
  final repository = ref.read(userRepositoryProvider);
  await repository.createTestUsers();
  // Refresh the all users provider after creating test users
  ref.invalidate(allActiveUsersProvider);
});
