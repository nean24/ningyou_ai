import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/providers/convex_client_provider.dart';
import '../../../shared/providers/secure_storage_provider.dart';
import '../data/auth_remote_data_source_impl.dart';
import '../data/auth_repository.dart';
import '../data/auth_repository_impl.dart';
import '../domain/auth_state.dart';

// ---------------------------------------------------------------------------
// Repository Provider
// ---------------------------------------------------------------------------
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final convexClient = ref.watch(convexClientProvider);
  final storage = ref.watch(secureStorageProvider);

  final dataSource = AuthRemoteDataSourceImpl(convexClient: convexClient);

  return AuthRepositoryImpl(
    remoteDataSource: dataSource,
    secureStorage: storage,
  );
});

// ---------------------------------------------------------------------------
// Auth Controller
// ---------------------------------------------------------------------------
final authControllerProvider =
    AsyncNotifierProvider<AuthController, AuthState>(AuthController.new);

class AuthController extends AsyncNotifier<AuthState> {
  @override
  Future<AuthState> build() async {
    final repo = ref.watch(authRepositoryProvider);

    await repo.restoreSession();
    return repo.currentState;
  }

  AuthRepository get _repo => ref.read(authRepositoryProvider);

  Future<void> signInWithGoogle() async {
    state = const AsyncLoading();
    try {
      await _repo.signInWithGoogle();
      state = AsyncData(_repo.currentState);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    state = const AsyncLoading();
    try {
      await _repo.signUpWithEmail(
        email: email,
        password: password,
        displayName: displayName,
      );
      state = AsyncData(_repo.currentState);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    try {
      await _repo.signInWithEmail(email: email, password: password);
      state = AsyncData(_repo.currentState);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> signInAnonymously() async {
    state = const AsyncLoading();
    try {
      await _repo.signInAnonymously();
      state = AsyncData(_repo.currentState);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> updateUserProfile({String? displayName, String? avatarUrl}) async {
    try {
      await _repo.updateUserProfile(displayName: displayName, avatarUrl: avatarUrl);
      state = AsyncData(_repo.currentState);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> signOut() async {
    state = const AsyncLoading();
    try {
      await _repo.signOut();
      state = AsyncData(_repo.currentState);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

// ---------------------------------------------------------------------------
// Convenience Providers
// ---------------------------------------------------------------------------

/// Whether the user is fully authenticated (not anonymous).
final isAuthenticatedProvider = Provider<bool>((ref) {
  final authState = ref.watch(authControllerProvider).valueOrNull;
  return authState is AuthAuthenticated;
});

/// Whether the user is in anonymous mode.
final isAnonymousProvider = Provider<bool>((ref) {
  final authState = ref.watch(authControllerProvider).valueOrNull;
  return authState is AuthAnonymous;
});

/// Current session token (null if not authenticated).
final sessionTokenProvider = Provider<String?>((ref) {
  final authState = ref.watch(authControllerProvider).valueOrNull;
  if (authState is AuthAuthenticated) return authState.sessionToken;
  return null;
});
