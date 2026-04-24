import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mobile_social_network/core/network/api_exception.dart';
import 'package:mobile_social_network/features/chat/domain/repositories/chat_repository.dart';
import 'package:mobile_social_network/features/chat/presentation/cubit/chat_blocks_state.dart';

class ChatBlocksCubit extends Cubit<ChatBlocksState> {
  ChatBlocksCubit(this._repository) : super(const ChatBlocksState());

  final ChatRepository _repository;

  Future<void> load() async {
    emit(state.copyWith(loading: true, clearError: true));
    try {
      final items = await _repository.fetchBlocks();
      emit(state.copyWith(items: items, loading: false));
    } on ApiException catch (e) {
      emit(state.copyWith(loading: false, lastError: e.userMessage));
    } catch (e) {
      emit(state.copyWith(loading: false, lastError: e.toString()));
    }
  }

  Future<void> unblock(String userId) async {
    try {
      await _repository.unblockUser(userId);
      emit(
        state.copyWith(
          items: state.items.where((b) => b.userId != userId).toList(),
        ),
      );
    } on ApiException catch (e) {
      emit(state.copyWith(lastError: e.userMessage));
    } catch (e) {
      emit(state.copyWith(lastError: e.toString()));
    }
  }

  void clearError() {
    if (state.lastError != null) {
      emit(state.copyWith(clearError: true));
    }
  }
}
