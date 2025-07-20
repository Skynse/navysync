import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';
import '../models/permission.dart';
import '../models/event.dart';

/// Service to handle authentication and permissions
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  NavySyncUser? _currentUser;

  // Get current user
  NavySyncUser? get currentUser => _currentUser;

  // Stream of authentication state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Get current Firebase user
  User? get firebaseUser => _auth.currentUser;

  // Load user data from Firestore
  Future<NavySyncUser?> loadUserData() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    try {
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        _currentUser = NavySyncUser.fromMap({
          'id': userDoc.id,
          ...userDoc.data() as Map<String, dynamic>,
        });
        return _currentUser;
      }
    } catch (e) {
      print('Error loading user data: $e');
    }

    return null;
  }

  // Check if user has permission for an action
  bool hasPermission(String action, String resourceType) {
    if (_currentUser == null) return false;

    // Admin has all permissions
    if (_currentUser!.isAdmin()) return true;

    return Permission.hasPermission(_currentUser!.roles, action, resourceType);
  }

  // Check if user can access an event
  bool canAccessEvent(Event event) {
    if (_currentUser == null) return false;

    // Admin has all access
    if (_currentUser!.isAdmin()) return true;

    // Event creator always has access
    if (event.createdBy == _currentUser!.id) return true;

    return event.canUserAccess(
      _currentUser!.id,
      _currentUser!.roles,
      _currentUser!.departmentId,
      _currentUser!.teamIds,
    );
  }

  // Check if user can manage a department
  bool canManageDepartment(String departmentId) {
    if (_currentUser == null) return false;

    if (_currentUser!.isAdmin()) return true;

    if (_currentUser!.isDepartmentHead(departmentId)) {
      return Permission.hasPermission(
        _currentUser!.roles,
        Permission.MANAGE,
        Permission.RESOURCE_DEPARTMENT,
      );
    }

    return false;
  }

  // Check if user can manage a team
  bool canManageTeam(String teamId) {
    if (_currentUser == null) return false;

    if (_currentUser!.isAdmin()) return true;

    if (_currentUser!.isTeamLeader(teamId)) {
      return Permission.hasPermission(
        _currentUser!.roles,
        Permission.MANAGE,
        Permission.RESOURCE_TEAM,
      );
    }

    return false;
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
    _currentUser = null;
  }
}
