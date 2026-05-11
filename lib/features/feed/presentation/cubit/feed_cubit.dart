import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import 'package:mobile_social_network/core/constants/media_upload_constants.dart';
import 'package:mobile_social_network/core/network/api_exception.dart';
import 'package:mobile_social_network/features/auth/domain/entities/user_entity.dart';
import 'package:mobile_social_network/features/feed/presentation/cubit/feed_state.dart';
import 'package:mobile_social_network/features/feed/presentation/cubit/publish_attachment.dart';
import 'package:mobile_social_network/features/feed/presentation/cubit/publishing_task.dart';
import 'package:mobile_social_network/features/media/data/media_upload_service.dart';
import 'package:mobile_social_network/features/posts/domain/entities/post_entity.dart';
import 'package:mobile_social_network/features/posts/domain/entities/post_visibility.dart';
import 'package:mobile_social_network/features/posts/domain/repositories/post_engagement_repository.dart';
import 'package:mobile_social_network/features/posts/domain/repositories/post_repository.dart';

class FeedCubit extends Cubit<FeedState> {
  FeedCubit({
    required PostRepository postRepository,
    required PostEngagementRepository postEngagementRepository,
    required MediaUploadService mediaUploadService,
  }) : _postRepository = postRepository,
       _postEngagement = postEngagementRepository,
       _mediaUpload = mediaUploadService,
       super(const FeedState());

  final PostRepository _postRepository;
  final PostEngagementRepository _postEngagement;
  final MediaUploadService _mediaUpload;
  final _uuid = const Uuid();
  final Set<String> _viewedPostIds = <String>{};

  UserEntity? _sessionUser;

  Future<void> loadNotes({UserEntity? currentUser}) async {
    if (currentUser != null) {
      _sessionUser = currentUser;
    }
    final posts = await _postRepository.getPosts();
    posts.sort((a, b) => (b.localId ?? 0).compareTo(a.localId ?? 0));
    final authorByUserId = <String, UserEntity>{};
    for (final p in posts) {
      final uid = p.userId;
      if (uid == null || uid.isEmpty) continue;
      final a = p.author;
      if (a != null && a.username.isNotEmpty) {
        authorByUserId[uid] = UserEntity(
          id: uid,
          email: '',
          username: a.username,
          avatarUrl: a.avatarUrl,
        );
      }
    }
    final effective = currentUser ?? _sessionUser;
    if (effective != null) {
      authorByUserId[effective.id] = effective;
    }
    final mergedLiked = _mergePostLiked(state.postLikedByMe, posts);
    emit(
      state.copyWith(
        posts: posts,
        authorByUserId: authorByUserId,
        postLikedByMe: mergedLiked,
      ),
    );
  }

  Map<String, bool> _mergePostLiked(
    Map<String, bool> prev,
    List<PostEntity> posts,
  ) {
    final ids = posts.map((p) => p.postId).whereType<String>().toSet();
    final next = <String, bool>{};
    for (final e in prev.entries) {
      if (ids.contains(e.key)) {
        next[e.key] = e.value;
      }
    }
    return next;
  }

  void clearPublishError() {
    emit(state.copyWith(clearPublishError: true));
  }

  void clearEngagementError() {
    emit(state.copyWith(clearEngagementError: true));
  }

  Future<void> togglePostLike(String postId) async {
    final idx = state.posts.indexWhere((p) => p.postId == postId);
    if (idx < 0) return;
    final original = state.posts[idx];
    final likedBefore = state.postLikedByMe[postId] ?? false;
    final nextLiked = !likedBefore;
    final delta = nextLiked ? 1 : -1;
    final updatedPost = original.copyWith(
      likesCount: (original.likesCount + delta).clamp(0, 1 << 30),
    );
    final newPosts = [...state.posts];
    newPosts[idx] = updatedPost;
    final newMap = Map<String, bool>.from(state.postLikedByMe);
    newMap[postId] = nextLiked;
    emit(state.copyWith(posts: newPosts, postLikedByMe: newMap));
    try {
      if (nextLiked) {
        await _postEngagement.addPostReaction(postId);
      } else {
        await _postEngagement.removePostReaction(postId);
      }
    } on ApiException catch (e) {
      final reverted = [...state.posts];
      reverted[idx] = original;
      final reMap = Map<String, bool>.from(state.postLikedByMe);
      reMap[postId] = likedBefore;
      emit(
        state.copyWith(
          posts: reverted,
          postLikedByMe: reMap,
          lastEngagementError: e.userMessage,
        ),
      );
    }
  }

  Future<void> recordPostView(String postId) async {
    if (!_viewedPostIds.add(postId)) return;
    try {
      await _postEngagement.recordPostView(postId);
    } catch (_) {
      _viewedPostIds.remove(postId);
    }
  }

  void patchPostCommentsCount(String postId, int delta) {
    final idx = state.posts.indexWhere((p) => p.postId == postId);
    if (idx < 0) return;
    final p = state.posts[idx];
    final next = p.copyWith(
      commentsCount: (p.commentsCount + delta).clamp(0, 1 << 30),
    );
    final list = [...state.posts];
    list[idx] = next;
    emit(state.copyWith(posts: list));
  }

  void replacePostInFeed(PostEntity server) {
    final idx = state.posts.indexWhere((p) => p.postId == server.postId);
    if (idx < 0) return;
    final list = [...state.posts];
    list[idx] = server;
    emit(state.copyWith(posts: list));
  }

  void mergeCommentLiked(String commentId, bool liked) {
    final m = Map<String, bool>.from(state.commentLikedByMe);
    m[commentId] = liked;
    emit(state.copyWith(commentLikedByMe: m));
  }

  void enqueuePublish({
    required String userId,
    required String content,
    PostVisibility visibility = PostVisibility.public,
    required List<PublishAttachment> attachments,
  }) {
    if (attachments.length > MediaUploadConstants.maxMediaPerPost) {
      emit(state.copyWith(lastPublishError: 'Too many attachments'));
      return;
    }
    for (final a in attachments) {
      if (a.sizeBytes > MediaUploadConstants.maxFileBytes) {
        emit(state.copyWith(lastPublishError: 'File too large'));
        return;
      }
    }

    final taskId = _uuid.v4();
    emit(
      state.copyWith(
        publishingTasks: [
          ...state.publishingTasks,
          PublishingTask(id: taskId, progress: 0),
        ],
      ),
    );

    Future(
      () => _runPublishTask(
        taskId: taskId,
        userId: userId,
        content: content,
        visibility: visibility,
        attachments: attachments,
      ),
    );
  }

  Future<void> _runPublishTask({
    required String taskId,
    required String userId,
    required String content,
    required PostVisibility visibility,
    required List<PublishAttachment> attachments,
  }) async {
    void setProgress(double p) {
      final next = state.publishingTasks.map((t) {
        if (t.id == taskId) {
          return PublishingTask(id: t.id, progress: p.clamp(0.0, 1.0));
        }
        return t;
      }).toList();
      emit(state.copyWith(publishingTasks: next));
    }

    try {
      final mediaIds = <String>[];
      var totalBytes = attachments.fold<int>(0, (a, x) => a + x.sizeBytes);
      if (totalBytes == 0) {
        totalBytes = 1;
      }
      var doneBytes = 0;

      for (var i = 0; i < attachments.length; i++) {
        final a = attachments[i];
        final uploadedId = await _mediaUpload.uploadLocalFile(
          path: a.path,
          contentType: a.contentType,
          fileSizeBytes: a.sizeBytes,
          onProgress: (fileProgress) {
            final overall =
                (doneBytes + fileProgress * a.sizeBytes) / totalBytes * 0.92;
            setProgress(overall);
          },
        );
        mediaIds.add(uploadedId);
        doneBytes += a.sizeBytes;
        setProgress((doneBytes / totalBytes) * 0.92);
      }

      setProgress(0.95);

      final date = DateTime.now().toIso8601String();
      await _postRepository.createPost(
        PostEntity(
          content: content,
          createdAt: date,
          userId: userId,
          visibility: visibility,
          mediaIds: mediaIds.isEmpty ? null : mediaIds,
        ),
      );

      setProgress(1);

      final without = state.publishingTasks
          .where((t) => t.id != taskId)
          .toList();
      emit(state.copyWith(publishingTasks: without));
      await loadNotes();
    } on ApiException catch (e) {
      _failTask(taskId, e.userMessage);
    } catch (e) {
      _failTask(taskId, e.toString());
    }
  }

  void _failTask(String taskId, String message) {
    final without = state.publishingTasks.where((t) => t.id != taskId).toList();
    emit(state.copyWith(publishingTasks: without, lastPublishError: message));
  }

  /// Вызывать после обновления поста вне очереди (например редактирование).
  Future<void> refreshNotes() => loadNotes();
}
