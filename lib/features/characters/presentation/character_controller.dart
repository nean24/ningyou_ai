import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database_provider.dart';
import '../../../shared/providers/convex_client_provider.dart';
import '../../auth/presentation/auth_controller.dart';
import '../data/character_local_data_source.dart';
import '../data/character_remote_data_source_impl.dart';
import '../data/character_repository.dart';
import '../data/character_repository_impl.dart';
import '../domain/character.dart';

// ---------------------------------------------------------------------------
// Repository provider (authed client for create)
// ---------------------------------------------------------------------------
final characterRepositoryProvider = Provider<CharacterRepository>((ref) {
  final client = ref.watch(convexClientProvider);
  final token = ref.watch(sessionTokenProvider);
  final authed = token != null ? client.withToken(token) : client;
  final dao = ref.watch(charactersDaoProvider);

  return CharacterRepositoryImpl(
    remote: CharacterRemoteDataSourceImpl(client: authed),
    local: CharacterLocalDataSource(dao),
  );
});

// ---------------------------------------------------------------------------
// Character list notifier
// ---------------------------------------------------------------------------
final characterListProvider =
    AsyncNotifierProvider<CharacterListNotifier, List<Character>>(
  CharacterListNotifier.new,
);

class CharacterListNotifier extends AsyncNotifier<List<Character>> {
  @override
  Future<List<Character>> build() {
    return ref.watch(characterRepositoryProvider).listPublic();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    try {
      final characters = await ref
          .read(characterRepositoryProvider)
          .listPublic(forceRefresh: true);
      state = AsyncData(characters);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<String?> getAvatarUploadUrl() async {
    try {
      return await ref.read(characterRepositoryProvider).getAvatarUploadUrl();
    } catch (e) {
      return null;
    }
  }

  Future<Character?> createCharacter({
    required String name,
    required String description,
    required String systemPrompt,
    String? greeting,
    List<String> traits = const [],
    String visibility = 'public',
    String? avatarStorageId,
  }) async {
    try {
      final character = await ref.read(characterRepositoryProvider).createCharacter(
            name: name,
            description: description,
            systemPrompt: systemPrompt,
            greeting: greeting,
            traits: traits,
            visibility: visibility,
            avatarStorageId: avatarStorageId,
          );
      
      // Update public list if character is public
      if (visibility == 'public') {
        final current = state.valueOrNull ?? [];
        state = AsyncData([character, ...current]);
      }
      
      // Also refresh My Characters list
      ref.invalidate(myCharactersProvider);
      
      return character;
    } catch (e) {
      return null;
    }
  }
}

// ---------------------------------------------------------------------------
// My Characters notifier
// ---------------------------------------------------------------------------
final myCharactersProvider =
    AsyncNotifierProvider<MyCharactersNotifier, List<Character>>(
  MyCharactersNotifier.new,
);

class MyCharactersNotifier extends AsyncNotifier<List<Character>> {
  @override
  Future<List<Character>> build() async {
    final token = ref.watch(sessionTokenProvider);
    if (token == null) return [];
    
    return ref.watch(characterRepositoryProvider).listByCreator();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    try {
      final characters = await ref
          .read(characterRepositoryProvider)
          .listByCreator(forceRefresh: true);
      state = AsyncData(characters);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

// ---------------------------------------------------------------------------
// Single character provider (used in detail screen)
// ---------------------------------------------------------------------------
final characterProvider =
    AsyncNotifierProviderFamily<CharacterNotifier, Character?, String>(
  CharacterNotifier.new,
);

class CharacterNotifier extends FamilyAsyncNotifier<Character?, String> {
  @override
  Future<Character?> build(String arg) {
    return ref.watch(characterRepositoryProvider).getById(arg);
  }
}
