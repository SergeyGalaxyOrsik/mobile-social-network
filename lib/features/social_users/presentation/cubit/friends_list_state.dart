import 'package:mobile_social_network/features/social_users/domain/entities/friend_list_item.dart';
import 'package:mobile_social_network/features/social_users/domain/entities/friends_list_sort.dart';

class FriendsListState {
  const FriendsListState({
    this.items = const [],
    this.total = 0,
    this.loading = false,
    this.loadingMore = false,
    this.lastError,
    this.query = '',
    this.sort = FriendsListSort.usernameAsc,
    this.usernamePrefix = '',
    this.friendshipAfter,
    this.friendshipBefore,
  });

  final List<FriendListItem> items;
  final int total;
  final bool loading;
  final bool loadingMore;
  final String? lastError;
  final String query;
  final FriendsListSort sort;
  final String usernamePrefix;
  final DateTime? friendshipAfter;
  final DateTime? friendshipBefore;

  bool get canLoadMore => items.length < total;

  FriendsListState copyWith({
    List<FriendListItem>? items,
    int? total,
    bool? loading,
    bool? loadingMore,
    String? lastError,
    bool clearError = false,
    String? query,
    FriendsListSort? sort,
    String? usernamePrefix,
    DateTime? friendshipAfter,
    bool updateFriendshipAfter = false,
    DateTime? friendshipBefore,
    bool updateFriendshipBefore = false,
  }) {
    return FriendsListState(
      items: items ?? this.items,
      total: total ?? this.total,
      loading: loading ?? this.loading,
      loadingMore: loadingMore ?? this.loadingMore,
      lastError: clearError ? null : (lastError ?? this.lastError),
      query: query ?? this.query,
      sort: sort ?? this.sort,
      usernamePrefix: usernamePrefix ?? this.usernamePrefix,
      friendshipAfter: updateFriendshipAfter
          ? friendshipAfter
          : this.friendshipAfter,
      friendshipBefore: updateFriendshipBefore
          ? friendshipBefore
          : this.friendshipBefore,
    );
  }
}
