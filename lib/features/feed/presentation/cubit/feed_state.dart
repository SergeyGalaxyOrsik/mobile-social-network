import 'package:equatable/equatable.dart';

import 'package:mobile_social_network/features/auth/domain/entities/user_entity.dart';
import 'package:mobile_social_network/features/feed/presentation/cubit/publishing_task.dart';
import 'package:mobile_social_network/features/posts/domain/entities/post_entity.dart';

class FeedState extends Equatable {
  const FeedState({
    this.posts = const [],
    this.authorByUserId = const {},
    this.publishingTasks = const [],
    this.lastPublishError,
    this.postLikedByMe = const {},
    this.commentLikedByMe = const {},
    this.lastEngagementError,
  });

  final List<PostEntity> posts;
  final Map<String, UserEntity> authorByUserId;
  final List<PublishingTask> publishingTasks;
  final String? lastPublishError;
  final Map<String, bool> postLikedByMe;
  final Map<String, bool> commentLikedByMe;
  final String? lastEngagementError;

  FeedState copyWith({
    List<PostEntity>? posts,
    Map<String, UserEntity>? authorByUserId,
    List<PublishingTask>? publishingTasks,
    String? lastPublishError,
    bool clearPublishError = false,
    Map<String, bool>? postLikedByMe,
    Map<String, bool>? commentLikedByMe,
    String? lastEngagementError,
    bool clearEngagementError = false,
  }) {
    return FeedState(
      posts: posts ?? this.posts,
      authorByUserId: authorByUserId ?? this.authorByUserId,
      publishingTasks: publishingTasks ?? this.publishingTasks,
      lastPublishError: clearPublishError
          ? null
          : (lastPublishError ?? this.lastPublishError),
      postLikedByMe: postLikedByMe ?? this.postLikedByMe,
      commentLikedByMe: commentLikedByMe ?? this.commentLikedByMe,
      lastEngagementError: clearEngagementError
          ? null
          : (lastEngagementError ?? this.lastEngagementError),
    );
  }

  double get aggregatePublishProgress {
    if (publishingTasks.isEmpty) return 0;
    var sum = 0.0;
    for (final t in publishingTasks) {
      sum += t.progress;
    }
    return sum / publishingTasks.length;
  }

  @override
  List<Object?> get props => [
    posts,
    authorByUserId,
    publishingTasks,
    lastPublishError,
    postLikedByMe,
    commentLikedByMe,
    lastEngagementError,
  ];
}
