import 'package:mobile_social_network/features/social_users/domain/entities/friend_request_item.dart';

class FriendRequestsState {
  const FriendRequestsState({
    this.incoming = const [],
    this.incomingTotal = 0,
    this.outgoing = const [],
    this.outgoingTotal = 0,
    this.loading = false,
    this.lastError,
    this.processingRequestId,
  });

  final List<FriendRequestItem> incoming;
  final int incomingTotal;
  final List<FriendRequestItem> outgoing;
  final int outgoingTotal;
  final bool loading;
  final String? lastError;
  final String? processingRequestId;

  FriendRequestsState copyWith({
    List<FriendRequestItem>? incoming,
    int? incomingTotal,
    List<FriendRequestItem>? outgoing,
    int? outgoingTotal,
    bool? loading,
    String? lastError,
    String? processingRequestId,
    bool clearError = false,
    bool clearProcessing = false,
  }) {
    return FriendRequestsState(
      incoming: incoming ?? this.incoming,
      incomingTotal: incomingTotal ?? this.incomingTotal,
      outgoing: outgoing ?? this.outgoing,
      outgoingTotal: outgoingTotal ?? this.outgoingTotal,
      loading: loading ?? this.loading,
      lastError: clearError ? null : (lastError ?? this.lastError),
      processingRequestId: clearProcessing
          ? null
          : (processingRequestId ?? this.processingRequestId),
    );
  }
}
