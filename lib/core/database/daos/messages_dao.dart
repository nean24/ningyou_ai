import 'package:sqflite/sqflite.dart';

import '../app_database.dart';

class MessagesDao {
  const MessagesDao(this._db);

  final AppDatabase _db;

  Future<List<Map<String, dynamic>>> getByConversation(
    String conversationId,
  ) async {
    final db = await _db.db;
    return db.query(
      'messages',
      where: 'conversation_id = ?',
      whereArgs: [conversationId],
      orderBy: 'created_at ASC',
    );
  }

  Future<void> upsertAll(List<Map<String, dynamic>> messages) async {
    final db = await _db.db;
    final batch = db.batch();

    for (final m in messages) {
      batch.insert(
        'messages',
        {
          'id': m['_id'] as String,
          'conversation_id': m['conversationId'] as String,
          'role': m['role'] as String,
          'content': m['content'] as String,
          'status': m['status'] as String? ?? 'sent',
          'model': m['model'] as String?,
          'created_at': m['createdAt'] as int,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<void> upsert(Map<String, dynamic> m) async {
    await upsertAll([m]);
  }

  /// Insert a pending outgoing message before the server confirms it.
  Future<void> insertPending({
    required String id,
    required String conversationId,
    required String content,
  }) async {
    final db = await _db.db;
    await db.insert(
      'messages',
      {
        'id': id,
        'conversation_id': conversationId,
        'role': 'user',
        'content': content,
        'status': 'pending',
        'model': null,
        'created_at': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateStatus(String id, String status) async {
    final db = await _db.db;
    await db.update(
      'messages',
      {'status': status},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteByConversation(String conversationId) async {
    final db = await _db.db;
    await db.delete(
      'messages',
      where: 'conversation_id = ?',
      whereArgs: [conversationId],
    );
  }
}
