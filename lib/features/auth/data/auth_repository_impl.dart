import 'dart:async';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../domain/app_user.dart';
import '../domain/auth_state.dart';
import 'auth_remote_data_source.dart';
import 'auth_remote_data_source_impl.dart';
import 'auth_repository.dart';

const _kSessionTokenKey = 'session_token';
const _kAnonymousIdKey = 'anonymous_id';
const _kUserIdKey = 'user_id';
const _kUserNameKey = 'user_name';
const _kUserEmailKey = 'user_email';
const _kUserAvatarKey = 'user_avatar';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required FlutterSecureStorage secureStorage,
  })  : _remote = remoteDataSource,
        _storage = secureStorage;

  final AuthRemoteDataSource _remote;
  final FlutterSecureStorage _storage;

  final _stateController = StreamController<AuthState>.broadcast();
  AuthState _currentState = const AuthInitial();
  String? _sessionToken;

  @override
  Stream<AuthState> get authStateChanges => _stateController.stream;

  @override
  AuthState get currentState => _currentState;

  @override
  String? get sessionToken => _sessionToken;

  void _emit(AuthState state) {
    _currentState = state;
    _stateController.add(state);
  }

  // -------------------------------------------------------------------------
  // Restore session from secure storage on app launch
  // -------------------------------------------------------------------------
  @override
  Future<void> restoreSession() async {
    _emit(const AuthLoading());

    try {
      // Check for authenticated session
      final token = await _storage.read(key: _kSessionTokenKey);
      if (token != null) {
        final user = await _remote.validateSession(token);
        if (user != null) {
          _sessionToken = token;
          // Restore cached profile
          final name = await _storage.read(key: _kUserNameKey) ?? '';
          final email = await _storage.read(key: _kUserEmailKey);
          final avatarUrl = await _storage.read(key: _kUserAvatarKey);
          final userId = await _storage.read(key: _kUserIdKey) ?? user.id;

          _emit(AuthAuthenticated(
            user: AppUser(
              id: userId,
              name: name,
              email: email,
              avatarUrl: avatarUrl,
              isAnonymous: false,
            ),
            sessionToken: token,
          ));
          return;
        }
        // Token expired — clean up
        await _clearSession();
      }

      // Check for anonymous session
      final anonymousId = await _storage.read(key: _kAnonymousIdKey);
      if (anonymousId != null) {
        _emit(AuthAnonymous(anonymousId: anonymousId));
        return;
      }

      _emit(const AuthUnauthenticated());
    } catch (e) {
      _emit(const AuthUnauthenticated());
    }
  }

  Future<void> _persistSession(String token, AppUser user) async {
    _sessionToken = token;
    await _storage.write(key: _kSessionTokenKey, value: token);
    await _storage.write(key: _kUserIdKey, value: user.id);
    await _storage.write(key: _kUserNameKey, value: user.name);
    if (user.email != null) {
      await _storage.write(key: _kUserEmailKey, value: user.email);
    }
    if (user.avatarUrl != null) {
      await _storage.write(key: _kUserAvatarKey, value: user.avatarUrl);
    }
  }

  // -------------------------------------------------------------------------
  // Google Sign-In
  // -------------------------------------------------------------------------
  @override
  Future<void> signInWithGoogle() async {
    _emit(const AuthLoading());
    try {
      final result = await _remote.signInWithGoogle();
      await _persistSession(result.sessionToken, result.user);
      _emit(AuthAuthenticated(user: result.user, sessionToken: result.sessionToken));
    } on AuthCancelledException {
      _emit(const AuthUnauthenticated());
    } catch (e) {
      _emit(AuthError(message: e.toString()));
    }
  }

  // -------------------------------------------------------------------------
  // Email Sign-Up
  // -------------------------------------------------------------------------
  @override
  Future<void> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    _emit(const AuthLoading());
    try {
      final result = await _remote.signUpWithEmail(
        email: email,
        password: password,
        displayName: displayName,
      );
      await _persistSession(result.sessionToken, result.user);
      _emit(AuthAuthenticated(user: result.user, sessionToken: result.sessionToken));
    } catch (e) {
      _emit(AuthError(message: e.toString()));
    }
  }

  // -------------------------------------------------------------------------
  // Email Sign-In
  // -------------------------------------------------------------------------
  @override
  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    _emit(const AuthLoading());
    try {
      final result = await _remote.signInWithEmail(email: email, password: password);
      await _persistSession(result.sessionToken, result.user);
      _emit(AuthAuthenticated(user: result.user, sessionToken: result.sessionToken));
    } catch (e) {
      _emit(AuthError(message: e.toString()));
    }
  }

  // -------------------------------------------------------------------------
  // Anonymous Sign-In
  // -------------------------------------------------------------------------
  @override
  Future<void> signInAnonymously() async {
    _emit(const AuthLoading());
    try {
      // Generate a local anonymous ID
      final anonymousId = 'anon_${DateTime.now().millisecondsSinceEpoch}';
      await _storage.write(key: _kAnonymousIdKey, value: anonymousId);
      _emit(AuthAnonymous(anonymousId: anonymousId));
    } catch (e) {
      _emit(AuthError(message: e.toString()));
    }
  }

  // -------------------------------------------------------------------------
  // Sign Out
  // -------------------------------------------------------------------------
  @override
  Future<void> signOut() async {
    final token = _sessionToken;
    if (token != null) {
      await _remote.signOut(token);
    }
    _sessionToken = null;
    await _clearSession();
    _emit(const AuthUnauthenticated());
  }

  @override
  Future<void> updateUserProfile({String? displayName, String? avatarUrl}) async {
    final current = _currentState;
    if (current is! AuthAuthenticated) return;

    if (displayName != null) {
      await _storage.write(key: _kUserNameKey, value: displayName);
    }
    if (avatarUrl != null) {
      await _storage.write(key: _kUserAvatarKey, value: avatarUrl);
    }

    _emit(AuthAuthenticated(
      user: current.user.copyWith(
        name: displayName ?? current.user.name,
        avatarUrl: avatarUrl ?? current.user.avatarUrl,
      ),
      sessionToken: current.sessionToken,
    ));
  }

  Future<void> _clearSession() async {
    await _storage.deleteAll();
  }
}
