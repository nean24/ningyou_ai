import '../domain/auth_state.dart';

abstract interface class AuthRepository {
  Stream<AuthState> get authStateChanges;
  AuthState get currentState;
  String? get sessionToken;

  Future<void> restoreSession();
  Future<void> signInWithGoogle();
  Future<void> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
  });
  Future<void> signInWithEmail({
    required String email,
    required String password,
  });
  Future<void> signInAnonymously();
  Future<void> signOut();
  Future<void> updateUserProfile({String? displayName, String? avatarUrl});
}
