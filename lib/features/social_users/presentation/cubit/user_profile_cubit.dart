import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mobile_social_network/core/network/api_exception.dart';
import 'package:mobile_social_network/features/social_users/domain/entities/profile_with_posts.dart';
import 'package:mobile_social_network/features/social_users/domain/entities/send_friend_request_result.dart';
import 'package:mobile_social_network/features/social_users/domain/repositories/social_users_repository.dart';
import 'package:mobile_social_network/features/social_users/presentation/cubit/user_profile_state.dart';

class UserProfileCubit extends Cubit<UserProfileState> {
  UserProfileCubit(
    this._repository,
    this.profileUserId,
  ) : super(const UserProfileState());

  final SocialUsersRepository _repository;
  final String profileUserId;

  static const _pageSize = 20;

  Future<void> load({bool reset = true}) async {
    if (reset) {
      emit(
        state.copyWith(
          loading: true,
          clearProfile: true,
          clearError: true,
          clearFeedback: true,
        ),
      );
    }
    try {
      final p = await _repository.getUserProfile(
        profileUserId,
        limit: _pageSize,
        offset: 0,
      );
      emit(state.copyWith(loading: false, profile: p));
    } on ApiException catch (e) {
      emit(
        state.copyWith(
          loading: false,
          errorMessage: e.userMessage,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          loading: false,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> loadMore() async {
    final cur = state.profile;
    if (cur == null || state.loadingMore || state.loading) return;
    if (cur.posts.length >= cur.postsTotal) return;
    emit(state.copyWith(loadingMore: true, clearError: true));
    try {
      final next = await _repository.getUserProfile(
        profileUserId,
        limit: _pageSize,
        offset: cur.posts.length,
      );
      final seen = cur.posts.map((p) => p.postId).toSet();
      final extra = next.posts.where((p) => p.postId != null && !seen.contains(p.postId)).toList();
      final merged = [...cur.posts, ...extra];
      final updated = ProfileWithPosts(
        userId: next.userId,
        username: next.username,
        bio: next.bio,
        birthDate: next.birthDate,
        avatarMediaId: next.avatarMediaId,
        avatarUrl: next.avatarUrl,
        relationship: next.relationship,
        posts: merged,
        postsTotal: next.postsTotal,
      );
      emit(state.copyWith(loadingMore: false, profile: updated));
    } on ApiException catch (e) {
      emit(
        state.copyWith(
          loadingMore: false,
          errorMessage: e.userMessage,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          loadingMore: false,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  void clearFeedback() {
    emit(state.copyWith(clearFeedback: true));
  }

  void clearError() {
    emit(state.copyWith(clearError: true));
  }

  Future<void> sendFriendRequest() async {
    emit(state.copyWith(actionBusy: true, clearError: true, clearFeedback: true));
    try {
      final r = await _repository.sendFriendRequest(profileUserId);
      await load(reset: true);
      emit(
        state.copyWith(
          actionBusy: false,
          feedback: r.outcome == SendFriendRequestOutcome.friends
              ? ProfileFeedback.becameFriends
              : ProfileFeedback.requestSent,
        ),
      );
    } on ApiException catch (e) {
      emit(state.copyWith(actionBusy: false, errorMessage: e.userMessage));
    } catch (e) {
      emit(state.copyWith(actionBusy: false, errorMessage: e.toString()));
    }
  }

  Future<void> cancelOutgoingRequest() async {
    emit(state.copyWith(actionBusy: true, clearError: true, clearFeedback: true));
    try {
      final id = await _repository.findOutgoingRequestIdForPeer(profileUserId);
      if (id == null) {
        emit(
          state.copyWith(
            actionBusy: false,
            errorMessage: 'outgoing_request_not_found',
          ),
        );
        return;
      }
      await _repository.cancelOutgoingFriendRequest(id);
      await load(reset: true);
      emit(
        state.copyWith(
          actionBusy: false,
          feedback: ProfileFeedback.requestCancelled,
        ),
      );
    } on ApiException catch (e) {
      emit(state.copyWith(actionBusy: false, errorMessage: e.userMessage));
    } catch (e) {
      emit(state.copyWith(actionBusy: false, errorMessage: e.toString()));
    }
  }

  Future<void> acceptIncomingRequest() async {
    emit(state.copyWith(actionBusy: true, clearError: true, clearFeedback: true));
    try {
      final id = await _repository.findIncomingRequestIdForPeer(profileUserId);
      if (id == null) {
        emit(
          state.copyWith(
            actionBusy: false,
            errorMessage: 'incoming_request_not_found',
          ),
        );
        return;
      }
      await _repository.acceptFriendRequest(id);
      await load(reset: true);
      emit(
        state.copyWith(
          actionBusy: false,
          feedback: ProfileFeedback.requestAccepted,
        ),
      );
    } on ApiException catch (e) {
      emit(state.copyWith(actionBusy: false, errorMessage: e.userMessage));
    } catch (e) {
      emit(state.copyWith(actionBusy: false, errorMessage: e.toString()));
    }
  }

  Future<void> declineIncomingRequest() async {
    emit(state.copyWith(actionBusy: true, clearError: true, clearFeedback: true));
    try {
      final id = await _repository.findIncomingRequestIdForPeer(profileUserId);
      if (id == null) {
        emit(
          state.copyWith(
            actionBusy: false,
            errorMessage: 'incoming_request_not_found',
          ),
        );
        return;
      }
      await _repository.declineFriendRequest(id);
      await load(reset: true);
      emit(
        state.copyWith(
          actionBusy: false,
          feedback: ProfileFeedback.requestDeclined,
        ),
      );
    } on ApiException catch (e) {
      emit(state.copyWith(actionBusy: false, errorMessage: e.userMessage));
    } catch (e) {
      emit(state.copyWith(actionBusy: false, errorMessage: e.toString()));
    }
  }

  Future<void> submitReport({
    required String reasonCode,
    String? details,
  }) async {
    emit(state.copyWith(actionBusy: true, clearError: true, clearFeedback: true));
    try {
      await _repository.reportUser(
        reportedUserId: profileUserId,
        reasonCode: reasonCode,
        details: details,
      );
      emit(
        state.copyWith(
          actionBusy: false,
          feedback: ProfileFeedback.reportSubmitted,
        ),
      );
    } on ApiException catch (e) {
      emit(state.copyWith(actionBusy: false, errorMessage: e.userMessage));
    } catch (e) {
      emit(state.copyWith(actionBusy: false, errorMessage: e.toString()));
    }
  }
}
