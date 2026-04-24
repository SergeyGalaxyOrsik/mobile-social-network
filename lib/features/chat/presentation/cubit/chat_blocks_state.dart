import 'package:equatable/equatable.dart';

import 'package:mobile_social_network/features/chat/domain/entities/direct_block.dart';

class ChatBlocksState extends Equatable {
  const ChatBlocksState({
    this.items = const [],
    this.loading = false,
    this.lastError,
  });

  final List<DirectBlock> items;
  final bool loading;
  final String? lastError;

  ChatBlocksState copyWith({
    List<DirectBlock>? items,
    bool? loading,
    String? lastError,
    bool clearError = false,
  }) {
    return ChatBlocksState(
      items: items ?? this.items,
      loading: loading ?? this.loading,
      lastError: clearError ? null : (lastError ?? this.lastError),
    );
  }

  @override
  List<Object?> get props => [items, loading, lastError];
}
