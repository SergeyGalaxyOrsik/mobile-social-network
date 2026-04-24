import 'package:mobile_social_network/features/social_users/domain/entities/profile_with_posts.dart';

enum ProfileFeedback {
  becameFriends,
  requestSent,
  requestCancelled,
  requestAccepted,
  requestDeclined,
  reportSubmitted,
}

class UserProfileState {
  const UserProfileState({
    this.profile,
    this.loading = false,
    this.loadingMore = false,
    this.actionBusy = false,
    this.errorMessage,
    this.feedback,
  });

  final ProfileWithPosts? profile;
  final bool loading;
  final bool loadingMore;
  final bool actionBusy;
  final String? errorMessage;
  final ProfileFeedback? feedback;

  UserProfileState copyWith({
    ProfileWithPosts? profile,
    bool? loading,
    bool? loadingMore,
    bool? actionBusy,
    String? errorMessage,
    ProfileFeedback? feedback,
    bool clearProfile = false,
    bool clearError = false,
    bool clearFeedback = false,
  }) {
    return UserProfileState(
      profile: clearProfile ? null : (profile ?? this.profile),
      loading: loading ?? this.loading,
      loadingMore: loadingMore ?? this.loadingMore,
      actionBusy: actionBusy ?? this.actionBusy,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      feedback: clearFeedback ? null : (feedback ?? this.feedback),
    );
  }
}
