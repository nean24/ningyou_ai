import '../domain/character.dart';

abstract interface class CharacterRepository {
  Future<List<Character>> listPublic({bool forceRefresh = false});
  Future<Character?> getById(String id, {bool forceRefresh = false});
  Future<Character> createCharacter({
    required String name,
    required String description,
    required String systemPrompt,
    String? greeting,
    List<String> traits,
    String visibility,
  });
}
