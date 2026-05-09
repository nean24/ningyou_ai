import 'dart:async';

import '../domain/conversation.dart';
import 'conversation_local_data_source.dart';
import 'conversation_remote_data_source.dart';
import 'conversation_repository.dart';

class ConversationRepositoryImpl implements ConversationRepository {
  const ConversationRepositoryImpl({
    required ConversationRemoteDataSource remote,
    required ConversationLocalDataSource local,
    required String? userId,
  })  : _remote = remote,
        _local = local,
        _userId = userId;

  final ConversationRemoteDataSource _remote;
  final ConversationLocalDataSource _local;
  final String? _userId;

  @override
  Future<Conversation> createConversation(String characterId) async {
    final res = await _remote.create(characterId);
    final raw = res['conversation'] as Map<String, dynamic>;
    final conversation = Conversation.fromRemote(raw);
    await _local.cache(raw);
    return conversation;
  }

  @override
  Future<List<Conversation>> listConversations({bool forceRefresh = false}) async {
    final userId = _userId;
    if (!forceRefresh && userId != null) {
      final cached = await _local.getByUser(userId);
      if (cached.isNotEmpty) {
        unawaited(_backgroundRefresh());
        return cached.map(Conversation.fromLocal).toList();
      }
    }
    return _fetchFromNetwork();
  }

  Future<List<Conversation>> _fetchFromNetwork() async {
    final remote = await _remote.listByUser();
    await _local.cacheAll(remote);
    return remote.map(Conversation.fromRemote).toList();
  }

  Future<void> _backgroundRefresh() async {
    try {
      await _fetchFromNetwork();
    } catch (_) {}
  }
}
