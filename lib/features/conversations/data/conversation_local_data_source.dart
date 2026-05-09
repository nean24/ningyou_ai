import '../../../core/database/daos/conversations_dao.dart';

class ConversationLocalDataSource {
  const ConversationLocalDataSource(this._dao);

  final ConversationsDao _dao;

  Future<List<Map<String, dynamic>>> getByUser(String userId) =>
      _dao.getByUser(userId);

  Future<void> cacheAll(List<Map<String, dynamic>> conversations) =>
      _dao.upsertAll(conversations);

  Future<void> cache(Map<String, dynamic> conversation) =>
      _dao.upsert(conversation);
}
