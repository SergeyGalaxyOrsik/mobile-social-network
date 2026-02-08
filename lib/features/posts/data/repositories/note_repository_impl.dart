import 'package:mobile_social_network/core/database/database_helper.dart';
import 'package:mobile_social_network/features/posts/domain/entities/note_entity.dart';
import 'package:mobile_social_network/features/posts/domain/repositories/note_repository.dart';

/// Реализация репозитория заметок (слой data).
class NoteRepositoryImpl implements NoteRepository {
  @override
  Future<List<NoteEntity>> getNotes() async {
    final db = await DatabaseHelper.instance.database;
    final List<Map<String, dynamic>> maps = await db.query('notes');
    return List.generate(maps.length, (i) => NoteEntity.fromMap(maps[i]));
  }

  @override
  Future<void> createNote(NoteEntity note) async {
    final db = await DatabaseHelper.instance.database;
    await db.insert('notes', note.toMap());
  }

  @override
  Future<void> updateNote(NoteEntity note) async {
    final db = await DatabaseHelper.instance.database;
    await db.update(
      'notes',
      note.toMap(),
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  @override
  Future<void> deleteNote(int id) async {
    final db = await DatabaseHelper.instance.database;
    await db.delete('notes', where: 'id = ?', whereArgs: [id]);
  }
}
