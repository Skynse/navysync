import 'package:firebase_auth/firebase_auth.dart';
import '../models/user.dart';
import '../constants.dart';
import 'repositories/user_repository.dart';

/// Service to handle authentication and user management
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserRepository _userRepository = UserRepository();

  NavySyncUser? _currentUser;

  // Get current user data
  NavySyncUser? get currentUser => _currentUser;

  // Stream of authentication state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Get current Firebase user
  User? get firebaseUser => _auth.currentUser;

  // Initialize the service and load user data if authenticated
  Future<void> initialize() async {
    final user = _auth.currentUser;
    if (user != null) {
      await loadUserData();
    }
  }

  // Load current user data from Firestore
  Future<NavySyncUser?> loadUserData() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    try {
      _currentUser = await _userRepository.getById(user.uid);
      return _currentUser;
    } catch (e) {
      throw Exception('Failed to load user data: $e');
    }
  }

  // Create new user account
  Future<UserCredential> createAccount({
    required String email,
    required String password,
    required String name,
    String departmentId = '',
    List<String> roles = const [UserRoles.member],
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create user profile in Firestore
      if (credential.user != null) {
        final now = DateTime.now();
        final navySyncUser = NavySyncUser(
          id: credential.user!.uid,
          name: name,
          email: email,
          departmentId: departmentId,
          roles: roles,
          createdAt: now,
          updatedAt: now,
        );

        await _userRepository.create(navySyncUser);
        _currentUser = navySyncUser;
      }

      return credential;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'admin-restricted-operation') {
        throw Exception(
          'User registration is currently disabled. Please contact an administrator.',
        );
      }
      throw Exception('Failed to create account: ${e.message}');
    } catch (e) {
      throw Exception('Failed to create account: $e');
    }
  }

  // Sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      await loadUserData();
      return credential;
    } catch (e) {
      throw Exception('Failed to sign in: $e');
    }
  }

  // Send email verification
  Future<void> sendEmailVerification() async {
    final user = _auth.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw Exception('Failed to send password reset email: $e');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      _currentUser = null;
    } catch (e) {
      throw Exception('Failed to sign out: $e');
    }
  }

  // Update user profile
  Future<void> updateProfile({
    String? name,
    String? profilePictureUrl,
    String? departmentId,
    List<String>? teamIds,
  }) async {
    if (_currentUser == null) throw Exception('No user logged in');

    try {
      final updatedUser = _currentUser!.copyWith(
        name: name,
        profilePictureUrl: profilePictureUrl,
        departmentId: departmentId,
        teamIds: teamIds,
      );

      await _userRepository.update(_currentUser!.id, updatedUser);
      _currentUser = updatedUser;
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  // Check if current user has permission
  bool hasPermission(String action, String resourceType) {
    return _currentUser?.hasPermission(action, resourceType) ?? false;
  }

  // Check if current user can access an event
  bool canAccessEvent(Map<String, dynamic> eventData) {
    return _currentUser?.canAccessEvent(eventData) ?? false;
  }

  // Check user roles
  bool isAdmin() => _currentUser?.isAdmin() ?? false;
  bool isDepartmentHead([String? deptId]) =>
      _currentUser?.isDepartmentHead(deptId) ?? false;
  bool isTeamLeader([String? teamId]) =>
      _currentUser?.isTeamLeader(teamId) ?? false;

  // Delete account
  Future<void> deleteAccount() async {
    final user = _auth.currentUser;
    if (user == null || _currentUser == null) {
      throw Exception('No user logged in');
    }

    try {
      // Delete user data from Firestore
      await _userRepository.delete(_currentUser!.id);

      // Delete Firebase Auth account
      await user.delete();

      _currentUser = null;
    } catch (e) {
      throw Exception('Failed to delete account: $e');
    }
  }
}
