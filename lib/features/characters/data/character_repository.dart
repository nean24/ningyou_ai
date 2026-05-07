import '../domain/character.dart';

abstract interface class CharacterRepository {
  Future<List<Character>> listPublic({bool forceRefresh = false});
  Future<Character?> getById(String id, {bool forceRefresh = false});
}
