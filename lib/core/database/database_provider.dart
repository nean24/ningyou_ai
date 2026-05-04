import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_database.dart';
import 'daos/characters_dao.dart';
import 'daos/conversations_dao.dart';
import 'daos/messages_dao.dart';

final appDatabaseProvider = Provider<AppDatabase>(
  (_) => AppDatabase.instance,
);

final charactersDaoProvider = Provider<CharactersDao>(
  (ref) => CharactersDao(ref.read(appDatabaseProvider)),
);

final conversationsDaoProvider = Provider<ConversationsDao>(
  (ref) => ConversationsDao(ref.read(appDatabaseProvider)),
);

final messagesDaoProvider = Provider<MessagesDao>(
  (ref) => MessagesDao(ref.read(appDatabaseProvider)),
);
