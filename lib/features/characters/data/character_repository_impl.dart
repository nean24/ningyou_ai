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
}
