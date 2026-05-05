class Conversation {
  const Conversation({
    required this.id,
    required this.characterId,
    required this.updatedAt,
    this.title,
  });

  final String id;
  final String characterId;
  final String? title;
  final DateTime updatedAt;
}
