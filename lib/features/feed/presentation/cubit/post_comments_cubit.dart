import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mobile_social_network/core/network/api_exception.dart';
import 'package:mobile_social_network/features/feed/presentation/cubit/feed_cubit.dart';
import 'package:mobile_social_network/features/feed/presentation/cubit/post_comments_state.dart';
import 'package:mobile_social_network/features/posts/domain/entities/comment_entity.dart';
import 'package:mobile_social_network/features/posts/domain/repositories/post_engagement_repository.dart';

class PostCommentsCubit extends Cubit<PostCommentsState> {
  PostCommentsCubit({
    required this.postId,
    required PostEngagementRepository engagement,
    required FeedCubit feedCubit,
    required this.currentUserId,
  }) : _engagement = engagement,
       _feedCubit = feedCubit,
       super(const PostCommentsState());

  final String postId;
  final String currentUserId;
  final PostEngagementRepository _engagement;
  final FeedCubit _feedCubit;

  static const _pageSize = 20;

  Future<void> loadInitial() async {
    emit(state.copyWith(loadingInitial: true, loadError: null));
    try {
      final page = await _engagement.listComments(
        postId,
        limit: _pageSize,
        offset: 0,
      );
      emit(
        state.copyWith(
          comments: page.items,
          total: page.total,
          loadingInitial: false,
        ),
      );
    } on ApiException catch (e) {
      emit(state.copyWith(loadingInitial: false, loadError: e.userMessage));
    }
  }

  Future<void> loadMore() async {
    if (!state.hasMore || state.loadingMore || state.loadingInitial) return;
    emit(state.copyWith(loadingMore: true));
    try {
      final page = await _engagement.listComments(
        postId,
        limit: _pageSize,
        offset: state.comments.length,
      );
      emit(
        state.copyWith(
          comments: [...state.comments, ...page.items],
          total: page.total,
          loadingMore: false,
        ),
      );
    } on ApiException catch (e) {
      emit(state.copyWith(loadingMore: false, lastActionError: e.userMessage));
    }
  }

  Future<void> sendComment(String raw) async {
    final text = raw.trim();
    if (text.isEmpty || state.sending) return;
    emit(state.copyWith(sending: true, clearActionError: true));
    try {
      final created = await _engagement.createComment(postId, text);
      _feedCubit.patchPostCommentsCount(postId, 1);
      emit(
        state.copyWith(
          comments: [created, ...state.comments],
          total: state.total + 1,
          sending: false,
        ),
      );
    } on ApiException catch (e) {
      emit(state.copyWith(sending: false, lastActionError: e.userMessage));
    }
  }

  Future<void> deleteComment(CommentEntity c) async {
    if (c.userId != currentUserId) return;
    final idx = state.comments.indexWhere((x) => x.commentId == c.commentId);
    if (idx < 0) return;
    final listBefore = List<CommentEntity>.from(state.comments);
    final totalBefore = state.total;
    final nextList = [...state.comments]..removeAt(idx);
    emit(
      state.copyWith(
        comments: nextList,
        total: (state.total - 1).clamp(0, 1 << 30),
        clearActionError: true,
      ),
    );
    try {
      await _engagement.deleteComment(postId, c.commentId);
      _feedCubit.patchPostCommentsCount(postId, -1);
    } on ApiException catch (e) {
      emit(
        state.copyWith(
          comments: listBefore,
          total: totalBefore,
          lastActionError: e.userMessage,
        ),
      );
    }
  }

  Future<void> toggleCommentLike(CommentEntity c) async {
    final idx = state.comments.indexWhere((x) => x.commentId == c.commentId);
    if (idx < 0) return;
    final likedBefore = _feedCubit.state.commentLikedByMe[c.commentId] ?? false;
    final nextLiked = !likedBefore;
    final delta = nextLiked ? 1 : -1;
    final original = state.comments[idx];
    final patched = original.copyWith(
      likesCount: (original.likesCount + delta).clamp(0, 1 << 30),
    );
    final list = [...state.comments];
    list[idx] = patched;
    _feedCubit.mergeCommentLiked(c.commentId, nextLiked);
    emit(state.copyWith(comments: list, clearActionError: true));
    try {
      if (nextLiked) {
        await _engagement.likeComment(postId, c.commentId);
      } else {
        await _engagement.unlikeComment(postId, c.commentId);
      }
    } on ApiException catch (e) {
      final reverted = [...state.comments];
      reverted[idx] = original;
      _feedCubit.mergeCommentLiked(c.commentId, likedBefore);
      emit(state.copyWith(comments: reverted, lastActionError: e.userMessage));
    }
  }

  void clearActionError() {
    emit(state.copyWith(clearActionError: true));
  }
}
