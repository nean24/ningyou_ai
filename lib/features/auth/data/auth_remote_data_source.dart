import '../domain/app_user.dart';

abstract interface class AuthRemoteDataSource {
  Future<({AppUser user, String sessionToken})> signInWithGoogle();

  Future<({AppUser user, String sessionToken})> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
  });

  Future<({AppUser user, String sessionToken})> signInWithEmail({
    required String email,
    required String password,
  });

  Future<AppUser?> validateSession(String sessionToken);

  Future<void> signOut(String sessionToken);
}
