abstract interface class CharacterRemoteDataSource {
  Future<List<Map<String, dynamic>>> listPublic();
  Future<Map<String, dynamic>?> getById(String id);
}
