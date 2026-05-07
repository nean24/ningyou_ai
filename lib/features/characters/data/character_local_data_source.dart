import '../../../core/database/daos/characters_dao.dart';

class CharacterLocalDataSource {
  const CharacterLocalDataSource(this._dao);

  final CharactersDao _dao;

  Future<List<Map<String, dynamic>>> getAll() => _dao.getAll();

  Future<Map<String, dynamic>?> getById(String id) => _dao.getById(id);

  Future<void> cacheAll(List<Map<String, dynamic>> characters) =>
      _dao.upsertAll(characters);

  Future<void> cache(Map<String, dynamic> character) => _dao.upsert(character);
}
