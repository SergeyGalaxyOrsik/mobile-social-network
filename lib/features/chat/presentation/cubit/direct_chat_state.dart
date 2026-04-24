import 'package:equatable/equatable.dart';

import 'package:mobile_social_network/features/chat/domain/entities/direct_message.dart';

class DirectChatState extends Equatable {
  const DirectChatState({
    required this.peerUserId,
    required this.currentUserId,
    this.peerDisplayName,
    this.messages = const [],
    this.loading = false,
    this.loadingMore = false,
    this.sending = false,
    this.conversationId,
    this.lastError,
    this.pendingMediaPaths = const [],
    this.hasMoreOlder = true,
  });

  final String peerUserId;
  final String currentUserId;
  final String? peerDisplayName;
  final List<DirectMessage> messages;
  final bool loading;
  final bool loadingMore;
  final bool sending;
  final String? conversationId;
  final String? lastError;
  final List<String> pendingMediaPaths;
  final bool hasMoreOlder;

  static const pageSize = 30;

  bool get canLoadMoreOlder => hasMoreOlder && !loadingMore;

  DirectChatState copyWith({
    String? peerDisplayName,
    List<DirectMessage>? messages,
    bool? loading,
    bool? loadingMore,
    bool? sending,
    String? conversationId,
    String? lastError,
    bool clearError = false,
    List<String>? pendingMediaPaths,
    bool? hasMoreOlder,
  }) {
    return DirectChatState(
      peerUserId: peerUserId,
      currentUserId: currentUserId,
      peerDisplayName: peerDisplayName ?? this.peerDisplayName,
      messages: messages ?? this.messages,
      loading: loading ?? this.loading,
      loadingMore: loadingMore ?? this.loadingMore,
      sending: sending ?? this.sending,
      conversationId: conversationId ?? this.conversationId,
      lastError: clearError ? null : (lastError ?? this.lastError),
      pendingMediaPaths: pendingMediaPaths ?? this.pendingMediaPaths,
      hasMoreOlder: hasMoreOlder ?? this.hasMoreOlder,
    );
  }

  @override
  List<Object?> get props => [
    peerUserId,
    currentUserId,
    peerDisplayName,
    messages,
    loading,
    loadingMore,
    sending,
    conversationId,
    lastError,
    pendingMediaPaths,
    hasMoreOlder,
  ];
}
