import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database_provider.dart';
import '../../../shared/providers/convex_client_provider.dart';
import '../../auth/presentation/auth_controller.dart';
import '../data/conversation_local_data_source.dart';
import '../data/conversation_remote_data_source_impl.dart';
import '../data/conversation_repository.dart';
import '../data/conversation_repository_impl.dart';
import '../domain/conversation.dart';

// ---------------------------------------------------------------------------
// Repository provider
// ---------------------------------------------------------------------------
final conversationRepositoryProvider = Provider<ConversationRepository>((ref) {
  final client = ref.watch(convexClientProvider);
  final token = ref.watch(sessionTokenProvider);
  final authed = token != null ? client.withToken(token) : client;
  final dao = ref.watch(conversationsDaoProvider);
  final userId = ref.watch(currentUserIdProvider);

  return ConversationRepositoryImpl(
    remote: ConversationRemoteDataSourceImpl(client: authed),
    local: ConversationLocalDataSource(dao),
    userId: userId,
  );
});

// ---------------------------------------------------------------------------
// Conversation list notifier
// ---------------------------------------------------------------------------
final conversationListProvider =
    AsyncNotifierProvider<ConversationListNotifier, List<Conversation>>(
  ConversationListNotifier.new,
);

class ConversationListNotifier extends AsyncNotifier<List<Conversation>> {
  @override
  Future<List<Conversation>> build() {
    return ref.watch(conversationRepositoryProvider).listConversations();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    try {
      final list = await ref
          .read(conversationRepositoryProvider)
          .listConversations(forceRefresh: true);
      state = AsyncData(list);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<Conversation?> createConversation(String characterId) async {
    try {
      final repo = ref.read(conversationRepositoryProvider);
      final conversation = await repo.createConversation(characterId);
      // Prepend to list
      final current = state.valueOrNull ?? [];
      state = AsyncData([conversation, ...current]);
      return conversation;
    } catch (e) {
      return null;
    }
  }
}
