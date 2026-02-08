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

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';

    await db.execute('''
      CREATE TABLE notes (
        id $idType,
        title $textType,
        description $textType,
        date $textType
      )
      ''');

    await db.execute('''
      CREATE TABLE users (
        id $idType,
        email $textType,
        displayName $textType,
        password $textType
      )
      ''');
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
