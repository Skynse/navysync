import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../models/user.dart';
import '../models/permission.dart';
import '../models/event.dart';

/// Service to handle authentication and permissions
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  DocumentSnapshot? _currentUser;

  // Get current user
  DocumentSnapshot? get currentUser => _currentUser;

  // Stream of authentication state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Get current Firebase user
  User? get firebaseUser => _auth.currentUser;

  // Load user data from Firestore
  Future<DocumentSnapshot?> loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    try {
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      _currentUser = userDoc;
    } catch (e) {
      print('Error loading user data: $e');
    }

    return null;
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
    _currentUser = null;
  }
}
