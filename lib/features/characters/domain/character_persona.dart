class CharacterPersona {
  const CharacterPersona({
    required this.systemPrompt,
    this.greeting,
    this.traits = const [],
  });

  final String systemPrompt;
  final String? greeting;
  final List<String> traits;
}
