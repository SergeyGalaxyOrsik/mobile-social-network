import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mobile_social_network/core/network/api_exception.dart';
import 'package:mobile_social_network/features/social_users/domain/entities/friends_list_sort.dart';
import 'package:mobile_social_network/features/social_users/domain/repositories/social_users_repository.dart';
import 'package:mobile_social_network/features/social_users/presentation/cubit/friends_list_state.dart';

class FriendsListCubit extends Cubit<FriendsListState> {
  FriendsListCubit(this._repository) : super(const FriendsListState());

  final SocialUsersRepository _repository;

  static const _pageSize = 20;

  Future<void> load({bool reset = true}) async {
    if (reset) {
      emit(
        state.copyWith(loading: true, clearError: true, items: [], total: 0),
      );
    } else {
      if (!state.canLoadMore || state.loadingMore) {
        return;
      }
      emit(state.copyWith(loadingMore: true, clearError: true));
    }
    final offset = reset ? 0 : state.items.length;
    try {
      final page = await _repository.getFriends(
        q: _effectiveQuery,
        sort: _effectiveSort,
        usernamePrefix: _prefixOrNull,
        friendshipCreatedAfter: state.friendshipAfter,
        friendshipCreatedBefore: state.friendshipBefore,
        limit: _pageSize,
        offset: offset,
      );
      final nextItems = reset ? page.items : [...state.items, ...page.items];
      emit(
        state.copyWith(
          items: nextItems,
          total: page.total,
          loading: false,
          loadingMore: false,
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

  String? get _effectiveQuery {
    final t = state.query.trim();
    return t.isEmpty ? null : t;
  }

  String? get _prefixOrNull {
    final t = state.usernamePrefix.trim();
    return t.isEmpty ? null : t;
  }

  /// При пустом `q` и режиме `relevance` API ведёт себя как `username_asc` — дублируем на клиенте явной сортировкой.
  FriendsListSort? get _effectiveSort {
    if (_effectiveQuery == null && state.sort == FriendsListSort.relevance) {
      return FriendsListSort.usernameAsc;
    }
    return state.sort;
  }

  void setQuery(String v) {
    emit(state.copyWith(query: v));
  }

  void setSort(FriendsListSort v) {
    emit(state.copyWith(sort: v));
  }

  void setUsernamePrefix(String v) {
    emit(state.copyWith(usernamePrefix: v));
  }

  void setFriendshipAfter(DateTime? v) {
    emit(state.copyWith(updateFriendshipAfter: true, friendshipAfter: v));
  }

  void setFriendshipBefore(DateTime? v) {
    emit(state.copyWith(updateFriendshipBefore: true, friendshipBefore: v));
  }

  void clearFilters() {
    emit(
      state.copyWith(
        query: '',
        sort: FriendsListSort.usernameAsc,
        usernamePrefix: '',
        updateFriendshipAfter: true,
        friendshipAfter: null,
        updateFriendshipBefore: true,
        friendshipBefore: null,
      ),
    );
  }

  void clearError() {
    emit(state.copyWith(clearError: true));
  }
}
