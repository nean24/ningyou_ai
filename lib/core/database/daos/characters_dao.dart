import 'dart:convert';

import 'package:sqflite/sqflite.dart';

import '../app_database.dart';

class CharactersDao {
  const CharactersDao(this._db);

  final AppDatabase _db;

  Future<List<Map<String, dynamic>>> getAll() async {
    final db = await _db.db;
    return db.query('characters', orderBy: 'updated_at DESC');
  }

  Future<Map<String, dynamic>?> getById(String id) async {
    final db = await _db.db;
    final rows = await db.query(
      'characters',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return rows.isEmpty ? null : rows.first;
  }

  Future<void> upsertAll(List<Map<String, dynamic>> characters) async {
    final db = await _db.db;
    final batch = db.batch();
    final now = DateTime.now().millisecondsSinceEpoch;

    for (final c in characters) {
      batch.insert(
        'characters',
        {
          'id': c['_id'] as String,
          'name': c['name'] as String,
          'description': c['description'] as String,
          'greeting': c['greeting'] as String?,
          'system_prompt': c['systemPrompt'] as String,
          'traits': jsonEncode(c['traits']),
          'avatar_url': c['avatarUrl'] as String?,
          'visibility': c['visibility'] as String,
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
}
