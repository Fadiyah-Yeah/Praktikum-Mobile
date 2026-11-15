import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  DatabaseService._();
  static final instance = DatabaseService._();
  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    final dir = await getDatabasesPath();
    _db = await openDatabase(
      p.join(dir, 'rick_morty_local.db'),
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE users(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT NOT NULL,
            email TEXT NOT NULL UNIQUE,
            password_hash TEXT NOT NULL,
            password_salt TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE favorites(
            user_id INTEGER NOT NULL,
            character_id INTEGER NOT NULL,
            PRIMARY KEY(user_id, character_id),
            FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE
          )
        ''');
      },
    );
    await _db!.execute('PRAGMA foreign_keys = ON');
    return _db!;
  }

  Future<int> register(Map<String, Object?> values) async =>
      (await database).insert('users', values);

  Future<Map<String, Object?>?> userByEmail(String email) async {
    final rows = await (await database).query(
      'users', where: 'email = ?', whereArgs: [email.toLowerCase()], limit: 1,
    );
    return rows.isEmpty ? null : rows.first;
  }

  Future<void> updateUser(int id, Map<String, Object?> values) async {
    await (await database).update('users', values, where: 'id = ?', whereArgs: [id]);
  }

  Future<List<int>> favoriteIds(int userId) async {
    final rows = await (await database).query(
      'favorites', columns: ['character_id'], where: 'user_id = ?', whereArgs: [userId],
    );
    return rows.map((r) => r['character_id'] as int).toList();
  }

  Future<void> addFavorite(int userId, int characterId) async {
    await (await database).insert(
      'favorites', {'user_id': userId, 'character_id': characterId},
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<void> removeFavorite(int userId, int characterId) async {
    await (await database).delete(
      'favorites', where: 'user_id = ? AND character_id = ?',
      whereArgs: [userId, characterId],
    );
  }
}
