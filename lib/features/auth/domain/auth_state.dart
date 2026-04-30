import 'app_user.dart';

/// Sealed class representing all possible authentication states.
sealed class AuthState {
  const AuthState();
}

/// Initial state — auth has not been determined yet (checking storage).
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Auth is being loaded (checking persisted session or signing in).
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// User is fully authenticated with a verified account.
class AuthAuthenticated extends AuthState {
  const AuthAuthenticated({required this.user, required this.sessionToken});

  final AppUser user;
  final String sessionToken;
}

/// User is in anonymous / guest mode.
class AuthAnonymous extends AuthState {
  const AuthAnonymous({required this.anonymousId});

  final String anonymousId;
}

/// No session — user needs to sign in.
class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

/// An error occurred during auth.
class AuthError extends AuthState {
  const AuthError({required this.message});

  final String message;
}
