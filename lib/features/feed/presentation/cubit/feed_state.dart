import 'package:equatable/equatable.dart';

import 'package:mobile_social_network/features/auth/domain/entities/user_entity.dart';
import 'package:mobile_social_network/features/posts/domain/entities/note_entity.dart';

class FeedState extends Equatable {
  const FeedState({
    this.notes = const [],
    this.pendingIds = const {},
    this.authorByUserId = const {},
  });

  final List<NoteEntity> notes;
  final Set<int> pendingIds;
  /// Карта userId -> пользователь для отображения автора поста.
  final Map<String, UserEntity> authorByUserId;

  @override
  List<Object?> get props => [notes, pendingIds, authorByUserId];
}
