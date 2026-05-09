import '../domain/conversation.dart';

abstract interface class ConversationRepository {
  Future<Conversation> createConversation(String characterId);
  Future<List<Conversation>> listConversations({bool forceRefresh = false});
}
