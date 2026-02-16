import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mobile_social_network/features/auth/domain/entities/user_entity.dart';
import 'package:mobile_social_network/features/auth/domain/repositories/user_repository.dart';
import 'package:mobile_social_network/features/posts/domain/repositories/note_repository.dart';

import 'feed_state.dart';

class FeedCubit extends Cubit<FeedState> {
  FeedCubit({
    required NoteRepository noteRepository,
    required UserRepository userRepository,
  })  : _noteRepository = noteRepository,
        _userRepository = userRepository,
        super(const FeedState());

  final NoteRepository _noteRepository;
  final UserRepository _userRepository;

  Future<void> loadNotes() async {
    final notes = await _noteRepository.getNotes();
    notes.sort((a, b) => (b.id ?? 0).compareTo(a.id ?? 0));
    final users = await _userRepository.getUsers();
    final authorByUserId = <String, UserEntity>{};
    for (final u in users) {
      authorByUserId[u.id] = u;
    }
    emit(FeedState(
      notes: notes,
      pendingIds: state.pendingIds,
      authorByUserId: authorByUserId,
    ));
  }

  void addPending(int id) {
    emit(FeedState(
      notes: state.notes,
      pendingIds: {...state.pendingIds, id},
      authorByUserId: state.authorByUserId,
    ));
  }

  void removePending(int id) {
    final next = Set<int>.from(state.pendingIds)..remove(id);
    emit(FeedState(
      notes: state.notes,
      pendingIds: next,
      authorByUserId: state.authorByUserId,
    ));
  }

  /// Call after updating a note (e.g. image path) so the feed refreshes.
  Future<void> refreshNotes() => loadNotes();
}
