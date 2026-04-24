import 'package:mobile_social_network/features/social_users/domain/entities/user_search_result.dart';

class UserSearchState {
  const UserSearchState({
    this.results = const [],
    this.loading = false,
    this.errorMessage,
  });

  final List<UserSearchResult> results;
  final bool loading;
  final String? errorMessage;

  UserSearchState copyWith({
    List<UserSearchResult>? results,
    bool? loading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return UserSearchState(
      results: results ?? this.results,
      loading: loading ?? this.loading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
