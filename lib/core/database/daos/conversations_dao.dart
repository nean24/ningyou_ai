import 'package:sqflite/sqflite.dart';

import '../app_database.dart';

class ConversationsDao {
  const ConversationsDao(this._db);

  final AppDatabase _db;

  Future<List<Map<String, dynamic>>> getByUser(String userId) async {
    final db = await _db.db;
    return db.query(
      'conversations',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'last_message_at DESC',
    );
  }

  Future<Map<String, dynamic>?> getById(String id) async {
    final db = await _db.db;
    final rows = await db.query(
      'conversations',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return rows.isEmpty ? null : rows.first;
  }

  Future<void> upsertAll(List<Map<String, dynamic>> conversations) async {
    final db = await _db.db;
    final batch = db.batch();
    final now = DateTime.now().millisecondsSinceEpoch;

    for (final c in conversations) {
      batch.insert(
        'conversations',
        {
          'id': c['_id'] as String,
          'user_id': c['userId'] as String?,
          'character_id': c['characterId'] as String,
          'title': c['title'] as String?,
          'last_message_at': c['lastMessageAt'] as int,
          'created_at': c['createdAt'] as int,
          'updated_at': c['updatedAt'] as int,
          'cached_at': now,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<void> upsert(Map<String, dynamic> c) async {
    await upsertAll([c]);
  }

  Future<void> updateTitle(String id, String title) async {
    final db = await _db.db;
    await db.update(
      'conversations',
      {'title': title},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> updateLastMessageAt(String id, int timestamp) async {
    final db = await _db.db;
    await db.update(
      'conversations',
      {'last_message_at': timestamp},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
