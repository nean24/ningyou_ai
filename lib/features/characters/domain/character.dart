import 'dart:convert';

class Character {
  const Character({
    required this.id,
    required this.name,
    required this.description,
    required this.systemPrompt,
    required this.traits,
    required this.visibility,
    required this.createdAt,
    required this.updatedAt,
    this.greeting,
    this.avatarUrl,
  });

  final String id;
  final String name;
  final String description;
  final String? greeting;
  final String systemPrompt;
  final List<String> traits;
  final String? avatarUrl;
  final String visibility;
  final int createdAt;
  final int updatedAt;

  factory Character.fromRemote(Map<String, dynamic> m) => Character(
        id: m['_id'] as String,
        name: m['name'] as String,
        description: m['description'] as String,
        greeting: m['greeting'] as String?,
        systemPrompt: m['systemPrompt'] as String,
        traits: (m['traits'] as List<dynamic>).cast<String>(),
        avatarUrl: m['avatarUrl'] as String?,
        visibility: m['visibility'] as String,
        createdAt: (m['createdAt'] as num).toInt(),
        updatedAt: (m['updatedAt'] as num).toInt(),
      );

  factory Character.fromLocal(Map<String, dynamic> row) => Character(
        id: row['id'] as String,
        name: row['name'] as String,
        description: row['description'] as String,
        greeting: row['greeting'] as String?,
        systemPrompt: row['system_prompt'] as String,
        traits: _parseLocalTraits(row['traits'] as String),
        avatarUrl: row['avatar_url'] as String?,
        visibility: row['visibility'] as String,
        createdAt: row['created_at'] as int,
        updatedAt: row['updated_at'] as int,
      );

  Map<String, dynamic> toRemoteMap() => {
        '_id': id,
        'name': name,
        'description': description,
        'greeting': greeting,
        'systemPrompt': systemPrompt,
        'traits': traits,
        'avatarUrl': avatarUrl,
        'visibility': visibility,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
      };
}

List<String> _parseLocalTraits(String value) {
  try {
    final decoded = jsonDecode(value);
    if (decoded is List) {
      return decoded.map((trait) => trait.toString()).toList();
    }
  } on FormatException {
    return value
        .split(',')
        .map((trait) => trait.trim())
        .where((trait) => trait.isNotEmpty)
        .toList();
  }

  return const [];
}
