abstract interface class CharacterRemoteDataSource {
  Future<String> getAvatarUploadUrl();
  Future<List<Map<String, dynamic>>> listByCreator();
  Future<List<Map<String, dynamic>>> listPublic();
  Future<Map<String, dynamic>?> getById(String id);
  Future<Map<String, dynamic>> create({
    required String name,
    required String description,
    required String systemPrompt,
    String? greeting,
    List<String> traits,
    String visibility,
    String? avatarStorageId,
  });
}
