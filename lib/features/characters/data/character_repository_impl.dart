import 'dart:async';

import '../domain/character.dart';
import 'character_local_data_source.dart';
import 'character_remote_data_source.dart';
import 'character_repository.dart';

class CharacterRepositoryImpl implements CharacterRepository {
  const CharacterRepositoryImpl({
    required CharacterRemoteDataSource remote,
    required CharacterLocalDataSource local,
  })  : _remote = remote,
        _local = local;

  final CharacterRemoteDataSource _remote;
  final CharacterLocalDataSource _local;

  @override
  Future<String> getAvatarUploadUrl() async {
    return _remote.getAvatarUploadUrl();
  }

  @override
  Future<List<Character>> listByCreator({bool forceRefresh = false}) async {
    // Only fetching from remote for My Characters for now
    final remote = await _remote.listByCreator();
    await _local.cacheAll(remote);
    return remote.map(Character.fromRemote).toList();
  }

  @override
  Future<List<Character>> listPublic({bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final cached = await _local.getAll();
      if (cached.isNotEmpty) {
        unawaited(_backgroundRefresh());
        return cached.map(Character.fromLocal).toList();
      }
    }
    final remote = await _remote.listPublic();
    await _local.cacheAll(remote);
    return remote.map(Character.fromRemote).toList();
  }

  @override
  Future<Character?> getById(String id, {bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final cached = await _local.getById(id);
      if (cached != null) return Character.fromLocal(cached);
    }
    final remote = await _remote.getById(id);
    if (remote == null) return null;
    await _local.cache(remote);
    return Character.fromRemote(remote);
  }

  Future<void> _backgroundRefresh() async {
    try {
      final remote = await _remote.listPublic();
      await _local.cacheAll(remote);
    } catch (_) {}
  }

  @override
  Future<Character> createCharacter({
    required String name,
    required String description,
    required String systemPrompt,
    String? greeting,
    List<String> traits = const [],
    String visibility = 'public',
    String? avatarStorageId,
  }) async {
    final raw = await _remote.create(
      name: name,
      description: description,
      systemPrompt: systemPrompt,
      greeting: greeting,
      traits: traits,
      visibility: visibility,
      avatarStorageId: avatarStorageId,
    );
    final character = Character.fromRemote(raw);
    await _local.cache(raw);
    return character;
  }
}
