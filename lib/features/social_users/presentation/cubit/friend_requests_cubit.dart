import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mobile_social_network/core/network/api_exception.dart';
import 'package:mobile_social_network/features/social_users/domain/repositories/social_users_repository.dart';
import 'package:mobile_social_network/features/social_users/presentation/cubit/friend_requests_state.dart';

class FriendRequestsCubit extends Cubit<FriendRequestsState> {
  FriendRequestsCubit(this._repository) : super(const FriendRequestsState());

  final SocialUsersRepository _repository;

  Future<void> load() async {
    emit(state.copyWith(loading: true, clearError: true));
    try {
      final incoming = await _repository.getIncomingFriendRequests();
      final outgoing = await _repository.getOutgoingFriendRequests();
      emit(
        state.copyWith(
          incoming: incoming.items,
          incomingTotal: incoming.total,
          outgoing: outgoing.items,
          outgoingTotal: outgoing.total,
          loading: false,
          clearProcessing: true,
        ),
      );
    } on ApiException catch (e) {
      emit(
        state.copyWith(
          loading: false,
          lastError: e.userMessage,
          clearProcessing: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          loading: false,
          lastError: e.toString(),
          clearProcessing: true,
        ),
      );
    }
  }

  void clearError() {
    emit(state.copyWith(clearError: true));
  }

  Future<void> accept(String requestId) async {
    emit(state.copyWith(processingRequestId: requestId, clearError: true));
    try {
      await _repository.acceptFriendRequest(requestId);
      await load();
    } on ApiException catch (e) {
      emit(state.copyWith(clearProcessing: true, lastError: e.userMessage));
    } catch (e) {
      emit(state.copyWith(clearProcessing: true, lastError: e.toString()));
    }
  }

  Future<void> decline(String requestId) async {
    emit(state.copyWith(processingRequestId: requestId, clearError: true));
    try {
      await _repository.declineFriendRequest(requestId);
      await load();
    } on ApiException catch (e) {
      emit(state.copyWith(clearProcessing: true, lastError: e.userMessage));
    } catch (e) {
      emit(state.copyWith(clearProcessing: true, lastError: e.toString()));
    }
  }

  Future<void> cancelOutgoing(String requestId) async {
    emit(state.copyWith(processingRequestId: requestId, clearError: true));
    try {
      await _repository.cancelOutgoingFriendRequest(requestId);
      await load();
    } on ApiException catch (e) {
      emit(state.copyWith(clearProcessing: true, lastError: e.userMessage));
    } catch (e) {
      emit(state.copyWith(clearProcessing: true, lastError: e.toString()));
    }
  }
}
