import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mobile_social_network/core/network/api_exception.dart';
import 'package:mobile_social_network/features/feed/presentation/cubit/post_search_state.dart';
import 'package:mobile_social_network/features/posts/domain/entities/post_entity.dart';
import 'package:mobile_social_network/features/posts/domain/entities/post_search_sort.dart';
import 'package:mobile_social_network/features/posts/domain/entities/post_visibility.dart';
import 'package:mobile_social_network/features/posts/domain/repositories/post_engagement_repository.dart';
import 'package:mobile_social_network/features/posts/domain/repositories/post_repository.dart';

class PostSearchCubit extends Cubit<PostSearchState> {
  PostSearchCubit({
    required PostRepository postRepository,
    required PostEngagementRepository postEngagement,
  }) : _postRepository = postRepository,
       _postEngagement = postEngagement,
       super(const PostSearchState());

  final PostRepository _postRepository;
  final PostEngagementRepository _postEngagement;

  static const _pageSize = 20;

  Future<void> load({bool reset = true}) async {
    if (reset) {
      emit(
        state.copyWith(
          loading: true,
          clearError: true,
          clearEngagementError: true,
          items: [],
          total: 0,
        ),
      );
    } else {
      if (!state.canLoadMore || state.loadingMore) {
        return;
      }
      emit(state.copyWith(loadingMore: true, clearError: true));
    }
    final offset = reset ? 0 : state.items.length;
    final q = state.query.trim();
    final author = state.authorUserId.trim();
    try {
      final page = await _postRepository.searchPosts(
        q: q.isEmpty ? null : q,
        sort: state.sort,
        authorUserId: author.isEmpty ? null : author,
        visibility: state.visibility,
        limit: _pageSize,
        offset: offset,
      );
      final nextItems = reset ? page.items : [...state.items, ...page.items];
      final likeMap = _mergeLikes(state.postLikedByMe, nextItems, reset: reset);
      emit(
        state.copyWith(
          items: nextItems,
          total: page.total,
          loading: false,
          loadingMore: false,
          postLikedByMe: likeMap,
        ),
      );
    } on ApiException catch (e) {
      emit(
        state.copyWith(
          loading: false,
          loadingMore: false,
          lastError: e.userMessage,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          loading: false,
          loadingMore: false,
          lastError: e.toString(),
        ),
      );
    }
  }

  Map<String, bool> _mergeLikes(
    Map<String, bool> prev,
    List<PostEntity> posts, {
    required bool reset,
  }) {
    final next = reset ? <String, bool>{} : Map<String, bool>.from(prev);
    for (final p in posts) {
      final id = p.postId;
      if (id == null) {
        continue;
      }
      if (reset) {
        next[id] = false;
      } else {
        next.putIfAbsent(id, () => false);
      }
    }
    return next;
  }

  Future<void> togglePostLike(String postId) async {
    final idx = state.items.indexWhere((p) => p.postId == postId);
    if (idx < 0) {
      return;
    }
    final original = state.items[idx];
    final likedBefore = state.postLikedByMe[postId] ?? false;
    final nextLiked = !likedBefore;
    final delta = nextLiked ? 1 : -1;
    final updated = original.copyWith(
      likesCount: (original.likesCount + delta).clamp(0, 1 << 30),
    );
    final newPosts = [...state.items];
    newPosts[idx] = updated;
    final m = Map<String, bool>.from(state.postLikedByMe);
    m[postId] = nextLiked;
    emit(
      state.copyWith(
        items: newPosts,
        postLikedByMe: m,
        clearEngagementError: true,
      ),
    );
    try {
      if (nextLiked) {
        await _postEngagement.addPostReaction(postId);
      } else {
        await _postEngagement.removePostReaction(postId);
      }
    } on ApiException catch (e) {
      final reverted = [...state.items];
      reverted[idx] = original;
      final reMap = Map<String, bool>.from(state.postLikedByMe);
      reMap[postId] = likedBefore;
      emit(
        state.copyWith(
          items: reverted,
          postLikedByMe: reMap,
          engagementError: e.userMessage,
        ),
      );
    }
  }

  void setQuery(String v) {
    emit(state.copyWith(query: v));
  }

  void setSort(PostSearchSort? v) {
    emit(v == null ? state.copyWith(clearSort: true) : state.copyWith(sort: v));
  }

  void setAuthorUserId(String v) {
    emit(state.copyWith(authorUserId: v));
  }

  void setVisibility(PostVisibility? v) {
    emit(
      v == null
          ? state.copyWith(clearVisibility: true)
          : state.copyWith(visibility: v),
    );
  }

  void clearError() {
    emit(state.copyWith(clearError: true));
  }

  void clearEngagementError() {
    emit(state.copyWith(clearEngagementError: true));
  }
}
