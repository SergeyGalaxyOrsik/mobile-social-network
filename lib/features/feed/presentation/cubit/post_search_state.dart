import 'package:mobile_social_network/features/posts/domain/entities/post_entity.dart';
import 'package:mobile_social_network/features/posts/domain/entities/post_search_sort.dart';
import 'package:mobile_social_network/features/posts/domain/entities/post_visibility.dart';

class PostSearchState {
  const PostSearchState({
    this.items = const [],
    this.total = 0,
    this.loading = false,
    this.loadingMore = false,
    this.lastError,
    this.query = '',
    this.sort, // null — дефолт сервера
    this.authorUserId = '',
    this.visibility, // null — любая
    this.postLikedByMe = const {},
    this.engagementError,
  });

  final List<PostEntity> items;
  final int total;
  final bool loading;
  final bool loadingMore;
  final String? lastError;
  final String query;
  final PostSearchSort? sort;
  final String authorUserId;
  final PostVisibility? visibility;
  final Map<String, bool> postLikedByMe;
  final String? engagementError;

  bool get canLoadMore => items.length < total;

  PostSearchState copyWith({
    List<PostEntity>? items,
    int? total,
    bool? loading,
    bool? loadingMore,
    String? lastError,
    bool clearError = false,
    String? query,
    PostSearchSort? sort,
    bool clearSort = false,
    String? authorUserId,
    PostVisibility? visibility,
    bool clearVisibility = false,
    Map<String, bool>? postLikedByMe,
    String? engagementError,
    bool clearEngagementError = false,
  }) {
    return PostSearchState(
      items: items ?? this.items,
      total: total ?? this.total,
      loading: loading ?? this.loading,
      loadingMore: loadingMore ?? this.loadingMore,
      lastError: clearError ? null : (lastError ?? this.lastError),
      query: query ?? this.query,
      sort: clearSort ? null : (sort ?? this.sort),
      authorUserId: authorUserId ?? this.authorUserId,
      visibility: clearVisibility ? null : (visibility ?? this.visibility),
      postLikedByMe: postLikedByMe ?? this.postLikedByMe,
      engagementError: clearEngagementError
          ? null
          : (engagementError ?? this.engagementError),
    );
  }
}
