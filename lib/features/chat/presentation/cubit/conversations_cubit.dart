import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mobile_social_network/core/network/api_exception.dart';
import 'package:mobile_social_network/features/chat/domain/repositories/chat_repository.dart';
import 'package:mobile_social_network/features/chat/presentation/cubit/conversations_state.dart';

class ConversationsCubit extends Cubit<ConversationsState> {
  ConversationsCubit(this._repository) : super(const ConversationsState());

  final ChatRepository _repository;

  static const _pageSize = 20;

  Future<void> load({bool reset = true}) async {
    if (reset) {
      emit(
        state.copyWith(
          loading: true,
          clearError: true,
          items: [],
          hasMore: true,
        ),
      );
    } else {
      if (!state.canLoadMore || state.loadingMore) {
        return;
      }
      emit(state.copyWith(loadingMore: true, clearError: true));
    }
    final offset = reset ? 0 : state.items.length;
    try {
      final page = await _repository.fetchConversations(
        limit: _pageSize,
        offset: offset,
      );
      final next = reset ? page : [...state.items, ...page];
      emit(
        state.copyWith(
          items: next,
          loading: false,
          loadingMore: false,
          hasMore: page.length >= _pageSize,
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

  void clearError() {
    if (state.lastError != null) {
      emit(state.copyWith(clearError: true));
    }
  }
}
