import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database_provider.dart';
import '../../../shared/providers/convex_client_provider.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../conversations/domain/message.dart';
import '../data/chat_local_data_source.dart';
import '../data/chat_remote_data_source_impl.dart';
import '../data/chat_repository.dart';
import '../data/chat_repository_impl.dart';

// ---------------------------------------------------------------------------
// Repository provider
// ---------------------------------------------------------------------------
final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  final client = ref.watch(convexClientProvider);
  final token = ref.watch(sessionTokenProvider);
  final authed = token != null ? client.withToken(token) : client;
  final dao = ref.watch(messagesDaoProvider);

  return ChatRepositoryImpl(
    remote: ChatRemoteDataSourceImpl(client: authed),
    local: ChatLocalDataSource(dao),
  );
});

// ---------------------------------------------------------------------------
// Chat state
// ---------------------------------------------------------------------------
class ChatState {
  const ChatState({
    this.messages = const [],
    this.isSending = false,
    this.error,
  });

  final List<Message> messages;
  final bool isSending;
  final String? error;

  ChatState copyWith({
    List<Message>? messages,
    bool? isSending,
    String? error,
    bool clearError = false,
  }) =>
      ChatState(
        messages: messages ?? this.messages,
        isSending: isSending ?? this.isSending,
        error: clearError ? null : (error ?? this.error),
      );
}

// ---------------------------------------------------------------------------
// Chat notifier (family by conversationId)
// ---------------------------------------------------------------------------
final chatProvider =
    NotifierProviderFamily<ChatNotifier, ChatState, String>(ChatNotifier.new);

class ChatNotifier extends FamilyNotifier<ChatState, String> {
  @override
  ChatState build(String arg) {
    _loadInitial();
    return const ChatState();
  }

  ChatRepository get _repo => ref.read(chatRepositoryProvider);
  String get _conversationId => arg;

  Future<void> _loadInitial() async {
    try {
      final messages = await _repo.listMessages(_conversationId);
      state = state.copyWith(messages: messages, clearError: true);
    } catch (_) {}
  }

  Future<void> refresh() async {
    try {
      final messages =
          await _repo.listMessages(_conversationId, forceRefresh: true);
      state = state.copyWith(messages: messages, clearError: true);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> sendMessage(String content) async {
    if (state.isSending || content.trim().isEmpty) return;

    final tempId = 'pending_${DateTime.now().millisecondsSinceEpoch}';
    final pending = Message(
      id: tempId,
      conversationId: _conversationId,
      role: MessageRole.user,
      content: content.trim(),
      status: MessageStatus.pending,
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );

    state = state.copyWith(
      messages: [...state.messages, pending],
      isSending: true,
      clearError: true,
    );

    try {
      final result = await _repo.sendMessage(_conversationId, content.trim());

      final updated = state.messages
          .where((m) => m.id != tempId)
          .toList()
        ..add(result.userMessage)
        ..add(result.assistantMessage);

      state = state.copyWith(messages: updated, isSending: false);
    } catch (e) {
      state = state.copyWith(
        messages: state.messages.where((m) => m.id != tempId).toList(),
        isSending: false,
        error: e.toString(),
      );
    }
  }

  void clearError() => state = state.copyWith(clearError: true);
}
