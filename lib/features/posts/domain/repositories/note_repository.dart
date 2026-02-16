import 'package:mobile_social_network/features/posts/domain/entities/note_entity.dart';

abstract class NoteRepository {
  Future<List<NoteEntity>> getNotes();
  Future<int> createNote(NoteEntity note);
  Future<void> updateNote(NoteEntity note);
  Future<void> deleteNote(int id);
}
