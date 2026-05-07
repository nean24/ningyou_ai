import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database_provider.dart';
import '../../../shared/providers/convex_client_provider.dart';
import '../data/character_local_data_source.dart';
import '../data/character_remote_data_source_impl.dart';
import '../data/character_repository.dart';
import '../data/character_repository_impl.dart';
import '../domain/character.dart';

// ---------------------------------------------------------------------------
// Repository provider
// ---------------------------------------------------------------------------
final characterRepositoryProvider = Provider<CharacterRepository>((ref) {
  final client = ref.watch(convexClientProvider);
  final dao = ref.watch(charactersDaoProvider);

  return CharacterRepositoryImpl(
    remote: CharacterRemoteDataSourceImpl(client: client),
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
