import 'package:mobile_social_network/features/posts/domain/entities/note_entity.dart';

/// Контракт репозитория заметок (доменный слой).
abstract class NoteRepository {
  Future<List<NoteEntity>> getNotes();
  Future<void> createNote(NoteEntity note);
  Future<void> updateNote(NoteEntity note);
  Future<void> deleteNote(int id);
}
