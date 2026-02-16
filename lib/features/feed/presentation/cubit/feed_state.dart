import 'package:equatable/equatable.dart';

import 'package:mobile_social_network/features/posts/domain/entities/note_entity.dart';

class FeedState extends Equatable {
  const FeedState({
    this.notes = const [],
    this.pendingIds = const {},
  });

  final List<NoteEntity> notes;
  final Set<int> pendingIds;

  @override
  List<Object?> get props => [notes, pendingIds];
}
