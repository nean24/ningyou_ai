abstract interface class ConversationRemoteDataSource {
  Future<Map<String, dynamic>> create(String characterId);
  Future<List<Map<String, dynamic>>> listByUser();
}
