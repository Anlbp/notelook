import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  AppDatabase._();
  static final AppDatabase instance = AppDatabase._();

  static const _fileName = 'notelook.db';
  static const _version = 2;

  Database? _db;
  int? _sessionUserId;

  int? get sessionUserId => _sessionUserId;

  void signIn(int userId) => _sessionUserId = userId;

  void signOut() => _sessionUserId = null;

  int requireUserId() {
    final id = _sessionUserId;
    if (id == null) {
      throw StateError('Nenhuma conta autenticada.');
    }
    return id;
  }

  Future<Database> get _database async {
    final cached = _db;
    if (cached != null) return cached;
    final path = join(await getDatabasesPath(), _fileName);
    _db = await openDatabase(
      path,
      version: _version,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (db, _) async {
        await db.execute('''
          CREATE TABLE users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            email TEXT NOT NULL COLLATE NOCASE UNIQUE,
            password TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE notes (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER NOT NULL,
            title TEXT NOT NULL,
            body TEXT NOT NULL,
            created_at INTEGER NOT NULL,
            FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute(
            'ALTER TABLE notes ADD COLUMN user_id INTEGER',
          );
          await db.execute('''
            UPDATE notes SET user_id = (
              SELECT id FROM users ORDER BY id LIMIT 1
            )
            WHERE user_id IS NULL
            AND EXISTS (SELECT 1 FROM users LIMIT 1)
          ''');
          await db.execute(
            'DELETE FROM notes WHERE user_id IS NULL',
          );
        }
      },
    );
    return _db!;
  }

  static String normalizeEmail(String email) => email.trim().toLowerCase();

  Future<Map<String, dynamic>?> findUserByEmail(String email) async {
    final db = await _database;
    final e = normalizeEmail(email);
    final rows = await db.query(
      'users',
      where: 'LOWER(email) = ?',
      whereArgs: [e],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return rows.first;
  }

  Future<int> insertUser({
    required String email,
    required String password,
  }) async {
    final db = await _database;
    return db.insert(
      'users',
      {
        'email': normalizeEmail(email),
        'password': password,
      },
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  Future<List<Map<String, dynamic>>> readNotes() async {
    final uid = requireUserId();
    final db = await _database;
    return db.query(
      'notes',
      where: 'user_id = ?',
      whereArgs: [uid],
      orderBy: 'created_at DESC',
    );
  }

  Future<void> insertNote({
    required String title,
    required String body,
  }) async {
    final uid = requireUserId();
    final db = await _database;
    await db.insert('notes', {
      'user_id': uid,
      'title': title,
      'body': body,
      'created_at': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<void> deleteAllNotes() async {
    final uid = requireUserId();
    final db = await _database;
    await db.delete('notes', where: 'user_id = ?', whereArgs: [uid]);
  }
}
