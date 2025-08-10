import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../models/user.dart';

// Auth service provider
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

// Firebase auth state provider
final firebaseAuthProvider = StreamProvider<User?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges;
});

// Current user provider
final currentUserProvider = StateNotifierProvider<CurrentUserNotifier, AsyncValue<NavySyncUser?>>((ref) {
  final authService = ref.watch(authServiceProvider);
  return CurrentUserNotifier(authService, ref);
});

class CurrentUserNotifier extends StateNotifier<AsyncValue<NavySyncUser?>> {
  final AuthService _authService;
  final Ref _ref;

  CurrentUserNotifier(this._authService, this._ref) : super(const AsyncValue.loading()) {
    _initialize();
  }

  Future<void> _initialize() async {
    // Listen to auth state changes
    _ref.listen<AsyncValue<User?>>(firebaseAuthProvider, (previous, next) {
      next.whenData((user) async {
        if (user != null) {
          await loadUser();
        } else {
          state = const AsyncValue.data(null);
        }
      });
    });

    // Load initial user data
    await loadUser();
  }

  Future<void> loadUser() async {
    try {
      state = const AsyncValue.loading();
      final user = await _authService.loadUserData();
      state = AsyncValue.data(user);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> signOut() async {
    try {
      await _authService.signOut();
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updateProfile({
    String? name,
    String? profilePictureUrl,
    String? departmentId,
    List<String>? teamIds,
  }) async {
    try {
      await _authService.updateProfile(
        name: name,
        profilePictureUrl: profilePictureUrl,
        departmentId: departmentId,
        teamIds: teamIds,
      );
      await loadUser();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}
