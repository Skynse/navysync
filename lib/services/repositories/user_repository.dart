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

  // Create test users for development
  Future<void> createTestUsers() async {
    try {
      final testUsers = [
        NavySyncUser(
          id: '', // Will be auto-generated
          name: 'John Doe',
          email: 'john.doe@navy.mil',
          departmentId: 'dept1',
          teamIds: ['team1'],
          roles: ['MEMBER'],
          permissions: {},
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isActive: true,
        ),
        NavySyncUser(
          id: '', // Will be auto-generated
          name: 'Jane Smith',
          email: 'jane.smith@navy.mil',
          departmentId: 'dept1',
          teamIds: ['team1', 'team2'],
          roles: ['TEAM_LEADER'],
          permissions: {},
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isActive: true,
        ),
        NavySyncUser(
          id: '', // Will be auto-generated
          name: 'Mike Johnson',
          email: 'mike.johnson@navy.mil',
          departmentId: 'dept2',
          teamIds: ['team2'],
          roles: ['MEMBER'],
          permissions: {},
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isActive: true,
        ),
        NavySyncUser(
          id: '', // Will be auto-generated
          name: 'Sarah Wilson',
          email: 'sarah.wilson@navy.mil',
          departmentId: 'dept1',
          teamIds: ['team1'],
          roles: ['MODERATOR'],
          permissions: {},
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isActive: true,
        ),
      ];

      for (final user in testUsers) {
        await create(user);
      }
      
      print('Created ${testUsers.length} test users');
    } catch (e) {
      print('Error creating test users: $e');
      throw Exception('Failed to create test users: $e');
    }
  }

  // Search users by name or email
  Future<List<NavySyncUser>> searchUsers(String query, {int limit = 10}) async {
    if (query.trim().isEmpty || query.trim().length < 2) return [];
    
    try {
      final lowercaseQuery = query.toLowerCase();
      
      // Get all active users and filter client-side to avoid index requirements
      final querySnapshot = await collection
          .where('isActive', isEqualTo: true)
          .limit(100) // Get a reasonable number for client-side filtering
          .get();

      print('Total users found: ${querySnapshot.docs.length}');
      
      final users = <NavySyncUser>[];

      // Filter users client-side by name or email
      for (final doc in querySnapshot.docs) {
        final user = fromFirestore(doc);
        print('Checking user: ${user.name} (${user.email})');
        
        final userName = user.name.toLowerCase();
        final userEmail = user.email.toLowerCase();
        
        // Split the user's name into words for better matching
        final nameWords = userName.split(' ');
        final queryWords = lowercaseQuery.split(' ');
        
        bool nameMatch = false;
        
        // Check if any query word matches any name word (for first/last name searches)
        for (final queryWord in queryWords) {
          if (queryWord.trim().isEmpty) continue;
          
          // Check if any name word starts with or contains the query word
          for (final nameWord in nameWords) {
            if (nameWord.startsWith(queryWord) || nameWord.contains(queryWord)) {
              nameMatch = true;
              break;
            }
          }
          
          if (nameMatch) break;
        }
        
        // Also check if the full name contains the query
        final fullNameMatch = userName.contains(lowercaseQuery);
        
        // Check email match
        final emailMatch = userEmail.contains(lowercaseQuery);
        
        if (nameMatch || fullNameMatch || emailMatch) {
          users.add(user);
          print('Match found: ${user.name} - nameMatch: $nameMatch, fullNameMatch: $fullNameMatch, emailMatch: $emailMatch');
        }
      }

      print('Filtered users: ${users.length}');

      // Sort by relevance (exact matches first, then by name)
      users.sort((a, b) {
        final aName = a.name.toLowerCase();
        final aEmail = a.email.toLowerCase();
        final bName = b.name.toLowerCase();
        final bEmail = b.email.toLowerCase();
        
        // Exact email match first
        if (aEmail == lowercaseQuery) return -1;
        if (bEmail == lowercaseQuery) return 1;
        
        // Exact name match
        if (aName == lowercaseQuery) return -1;
        if (bName == lowercaseQuery) return 1;
        
        // Name starts with query
        if (aName.startsWith(lowercaseQuery) && !bName.startsWith(lowercaseQuery)) return -1;
        if (bName.startsWith(lowercaseQuery) && !aName.startsWith(lowercaseQuery)) return 1;
        
        // First word of name starts with query (for first name matches)
        final aFirstWord = aName.split(' ').first;
        final bFirstWord = bName.split(' ').first;
        if (aFirstWord.startsWith(lowercaseQuery) && !bFirstWord.startsWith(lowercaseQuery)) return -1;
        if (bFirstWord.startsWith(lowercaseQuery) && !aFirstWord.startsWith(lowercaseQuery)) return 1;
        
        // Email starts with query
        if (aEmail.startsWith(lowercaseQuery) && !bEmail.startsWith(lowercaseQuery)) return -1;
        if (bEmail.startsWith(lowercaseQuery) && !aEmail.startsWith(lowercaseQuery)) return 1;
        
        // Alphabetical by name
        return aName.compareTo(bName);
      });

      return users.take(limit).toList();
    } catch (e) {
      print('Search error: $e');
      throw Exception('Failed to search users: $e');
    }
  }
}
