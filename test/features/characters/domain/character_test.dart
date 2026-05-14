import 'package:flutter_test/flutter_test.dart';
import 'package:ningyou/features/characters/domain/character.dart';

void main() {
  group('Character.fromLocal', () {
    test('parses legacy comma-separated cached traits', () {
      final character = Character.fromLocal({
        'id': 'character-1',
        'name': 'Hana',
        'description': 'A gentle florist.',
        'greeting': 'Hello',
        'system_prompt': 'Stay warm.',
        'traits': 'Gentle,Poetic,Warm',
        'avatar_url': null,
        'visibility': 'public',
        'created_at': 1,
        'updated_at': 2,
      });

      expect(character.traits, ['Gentle', 'Poetic', 'Warm']);
    });
  });
}
