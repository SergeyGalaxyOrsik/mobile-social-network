import 'package:equatable/equatable.dart';

import 'package:mobile_social_network/features/posts/domain/entities/comment_entity.dart';

class PostCommentsState extends Equatable {
  const PostCommentsState({
    this.comments = const [],
    this.total = 0,
    this.loadingInitial = false,
    this.loadingMore = false,
    this.loadError,
    this.lastActionError,
    this.sending = false,
  });

  final List<CommentEntity> comments;
  final int total;
  final bool loadingInitial;
  final bool loadingMore;
  final String? loadError;
  final String? lastActionError;
  final bool sending;

  bool get hasMore => comments.length < total;

  PostCommentsState copyWith({
    List<CommentEntity>? comments,
    int? total,
    bool? loadingInitial,
    bool? loadingMore,
    String? loadError,
    String? lastActionError,
    bool clearActionError = false,
    bool? sending,
  }) {
    return PostCommentsState(
      comments: comments ?? this.comments,
      total: total ?? this.total,
      loadingInitial: loadingInitial ?? this.loadingInitial,
      loadingMore: loadingMore ?? this.loadingMore,
      loadError: loadError ?? this.loadError,
      lastActionError: clearActionError
          ? null
          : (lastActionError ?? this.lastActionError),
      sending: sending ?? this.sending,
    );
  }

  @override
  List<Object?> get props => [
        comments,
        total,
        loadingInitial,
        loadingMore,
        loadError,
        lastActionError,
        sending,
      ];
}
