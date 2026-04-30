import 'package:google_sign_in/google_sign_in.dart';

import '../../../core/config/env.dart';
import '../../../core/network/convex_http_client.dart';
import '../domain/app_user.dart';
import 'auth_remote_data_source.dart';

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl({
    required ConvexHttpClient convexClient,
    GoogleSignIn? googleSignIn,
  })  : _convex = convexClient,
        _googleSignIn = googleSignIn ??
            GoogleSignIn(
              scopes: ['email', 'profile'],
              serverClientId: Env.googleClientId.isNotEmpty
                  ? Env.googleClientId
                  : null,
            );

  final ConvexHttpClient _convex;
  final GoogleSignIn _googleSignIn;

  @override
  Future<({AppUser user, String sessionToken})> signInWithGoogle() async {
    // Trigger Google Sign-In flow
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      throw const AuthCancelledException();
    }

    final googleAuth = await googleUser.authentication;
    final idToken = googleAuth.idToken;

    if (idToken == null) {
      throw const AuthException('Failed to get Google ID token');
    }

    // Validate with Convex backend and create session
    final response = await _convex.post(
      '/auth/google/signin',
      body: {'idToken': idToken},
    );

    final sessionToken = response['sessionToken'] as String;
    final userId = response['userId'] as String;

    final user = AppUser(
      id: userId,
      name: googleUser.displayName ?? googleUser.email,
      email: googleUser.email,
      avatarUrl: googleUser.photoUrl,
      isAnonymous: false,
    );

    return (user: user, sessionToken: sessionToken);
  }

  @override
  Future<AppUser?> validateSession(String sessionToken) async {
    try {
      final authedClient = _convex.withToken(sessionToken);
      final response = await authedClient.post('/auth/validate');

      if (response['valid'] == true) {
        final userId = response['userId'] as String?;
        if (userId == null) return null;

        // Return a minimal user — the full profile can be fetched separately
        return AppUser(
          id: userId,
          name: '',
          isAnonymous: false,
        );
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<({AppUser user, String sessionToken})> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final response = await _convex.post(
      '/auth/email/register',
      body: {'email': email, 'password': password, 'displayName': displayName},
    );

    final sessionToken = response['sessionToken'] as String;
    final userId = response['userId'] as String;

    return (
      user: AppUser(
        id: userId,
        name: displayName,
        email: email,
        isAnonymous: false,
      ),
      sessionToken: sessionToken,
    );
  }

  @override
  Future<({AppUser user, String sessionToken})> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final response = await _convex.post(
      '/auth/email/signin',
      body: {'email': email, 'password': password},
    );

    final sessionToken = response['sessionToken'] as String;
    final userId = response['userId'] as String;
    final displayName = response['displayName'] as String? ?? '';

    return (
      user: AppUser(
        id: userId,
        name: displayName,
        email: email,
        isAnonymous: false,
      ),
      sessionToken: sessionToken,
    );
  }

  @override
  Future<void> signOut(String sessionToken) async {
    try {
      final authedClient = _convex.withToken(sessionToken);
      await authedClient.post('/auth/signout');
    } catch (_) {
      // Ignore server errors on sign-out; still clear local session
    }
    await _googleSignIn.signOut();
  }
}

// ---------------------------------------------------------------------------
// Exceptions
// ---------------------------------------------------------------------------

class AuthException implements Exception {
  const AuthException(this.message);
  final String message;
  @override
  String toString() => 'AuthException: $message';
}

class AuthCancelledException implements Exception {
  const AuthCancelledException();
  @override
  String toString() => 'AuthCancelledException: User cancelled sign-in';
}
