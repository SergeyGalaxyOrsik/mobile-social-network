import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mobile_social_network/features/posts/domain/repositories/note_repository.dart';

import 'feed_state.dart';

class FeedCubit extends Cubit<FeedState> {
  FeedCubit({required NoteRepository noteRepository})
      : _noteRepository = noteRepository,
        super(const FeedState());

  final NoteRepository _noteRepository;

  Future<void> loadNotes() async {
    final notes = await _noteRepository.getNotes();
    notes.sort((a, b) => (b.id ?? 0).compareTo(a.id ?? 0));
    emit(FeedState(notes: notes, pendingIds: state.pendingIds));
  }

  void addPending(int id) {
    emit(FeedState(
      notes: state.notes,
      pendingIds: {...state.pendingIds, id},
    ));
  }

  void removePending(int id) {
    final next = Set<int>.from(state.pendingIds)..remove(id);
    emit(FeedState(notes: state.notes, pendingIds: next));
  }

  /// Call after updating a note (e.g. image path) so the feed refreshes.
  Future<void> refreshNotes() => loadNotes();
}
