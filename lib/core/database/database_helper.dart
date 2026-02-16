import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// Общий хелпер для работы с SQLite (схема БД без привязки к фичам).
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();

  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('notes.db');
    return _database!;
  }

  static const int _dbVersion = 3;

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';

    if (version >= 3) {
      await db.execute('''
        CREATE TABLE notes (
          id $idType,
          note $textType,
          date $textType,
          image TEXT
        )
      ''');
    } else {
      await db.execute('''
        CREATE TABLE notes (
          id $idType,
          title $textType,
          description $textType,
          date $textType
        )
      ''');
    }

    await db.execute('''
      CREATE TABLE users (
        id $idType,
        email $textType,
        displayName $textType,
        password $textType,
        avatarUrl TEXT
      )
      ''');
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE users ADD COLUMN avatarUrl TEXT');
    }
    if (oldVersion < 3) {
      await db.execute('''
        CREATE TABLE notes_new (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          note TEXT NOT NULL,
          date TEXT NOT NULL,
          image TEXT
        )
      ''');
      await db.execute('''
        INSERT INTO notes_new (id, note, date, image)
        SELECT id, COALESCE(note, description), date, image FROM notes
      ''');
      await db.execute('DROP TABLE notes');
      await db.execute('ALTER TABLE notes_new RENAME TO notes');
      await db.execute('''
        INSERT OR REPLACE INTO sqlite_sequence (name, seq)
        SELECT 'notes', COALESCE(MAX(id), 0) FROM notes
      ''');
    }
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
