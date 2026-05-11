import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mobile_social_network/core/network/api_exception.dart';
import 'package:mobile_social_network/features/social_users/domain/repositories/social_users_repository.dart';
import 'package:mobile_social_network/features/social_users/presentation/cubit/user_search_state.dart';

class UserSearchCubit extends Cubit<UserSearchState> {
  UserSearchCubit(this._repository) : super(const UserSearchState());

  final SocialUsersRepository _repository;
  Timer? _debounce;

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }

  void onQueryChanged(String raw) {
    _debounce?.cancel();
    final trimmed = raw.trim();
    if (trimmed.isEmpty) {
      emit(state.copyWith(results: const [], loading: false, clearError: true));
      return;
    }
    if (trimmed.length > 100) {
      return;
    }
    emit(state.copyWith(loading: true, clearError: true));
    _debounce = Timer(const Duration(milliseconds: 400), () {
      _runSearch(trimmed);
    });
  }

  void clearError() {
    emit(state.copyWith(clearError: true));
  }

  Future<void> _runSearch(String query) async {
    try {
      final list = await _repository.searchUsers(query: query);
      emit(state.copyWith(results: list, loading: false, clearError: true));
    } on ApiException catch (e) {
      emit(state.copyWith(loading: false, errorMessage: e.userMessage));
    } catch (e) {
      emit(state.copyWith(loading: false, errorMessage: e.toString()));
    }
  }
}
