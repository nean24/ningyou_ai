class Conversation {
  const Conversation({
    required this.id,
    required this.characterId,
    required this.lastMessageAt,
    required this.createdAt,
    required this.updatedAt,
    this.userId,
    this.title,
  });

  final String id;
  final String characterId;
  final String? userId;
  final String? title;
  final int lastMessageAt;
  final int createdAt;
  final int updatedAt;

  factory Conversation.fromRemote(Map<String, dynamic> m) => Conversation(
        id: m['_id'] as String,
        characterId: m['characterId'] as String,
        userId: m['userId'] as String?,
        title: m['title'] as String?,
        lastMessageAt: (m['lastMessageAt'] as num).toInt(),
        createdAt: (m['createdAt'] as num).toInt(),
        updatedAt: (m['updatedAt'] as num).toInt(),
      );

  factory Conversation.fromLocal(Map<String, dynamic> row) => Conversation(
        id: row['id'] as String,
        characterId: row['character_id'] as String,
        userId: row['user_id'] as String?,
        title: row['title'] as String?,
        lastMessageAt: row['last_message_at'] as int,
        createdAt: row['created_at'] as int,
        updatedAt: row['updated_at'] as int,
      );
}
