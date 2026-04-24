import 'package:equatable/equatable.dart';

import 'package:mobile_social_network/features/chat/domain/entities/direct_conversation.dart';

class ConversationsState extends Equatable {
  const ConversationsState({
    this.items = const [],
    this.loading = false,
    this.loadingMore = false,
    this.hasMore = true,
    this.lastError,
  });

  final List<DirectConversation> items;
  final bool loading;
  final bool loadingMore;
  final bool hasMore;
  final String? lastError;

  bool get canLoadMore => hasMore && !loadingMore;

  ConversationsState copyWith({
    List<DirectConversation>? items,
    bool? loading,
    bool? loadingMore,
    bool? hasMore,
    String? lastError,
    bool clearError = false,
  }) {
    return ConversationsState(
      items: items ?? this.items,
      loading: loading ?? this.loading,
      loadingMore: loadingMore ?? this.loadingMore,
      hasMore: hasMore ?? this.hasMore,
      lastError: clearError ? null : (lastError ?? this.lastError),
    );
  }

  @override
  List<Object?> get props => [items, loading, loadingMore, hasMore, lastError];
}
