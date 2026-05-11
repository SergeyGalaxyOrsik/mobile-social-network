import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mobile_social_network/core/utils/user_avatar.dart';
import 'package:mobile_social_network/features/chat/domain/entities/direct_conversation.dart';
import 'package:mobile_social_network/features/chat/domain/repositories/chat_repository.dart';
import 'package:mobile_social_network/features/chat/presentation/chat_navigation.dart';
import 'package:mobile_social_network/features/chat/presentation/cubit/conversations_cubit.dart';
import 'package:mobile_social_network/features/chat/presentation/cubit/conversations_state.dart';
import 'package:mobile_social_network/l10n/app_localizations.dart';

class ConversationsPage extends StatelessWidget {
  const ConversationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocProvider(
      create: (_) => ConversationsCubit(context.read<ChatRepository>())..load(),
      child: Scaffold(
        appBar: AppBar(title: Text(l10n.chatConversationsTitle)),
        body: BlocConsumer<ConversationsCubit, ConversationsState>(
          listenWhen: (a, b) => a.lastError != b.lastError,
          listener: (context, state) {
            if (state.lastError != null && context.mounted) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.lastError!)));
              context.read<ConversationsCubit>().clearError();
            }
          },
          builder: (context, state) {
            if (state.loading && state.items.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.items.isEmpty) {
              return RefreshIndicator(
                onRefresh: () => context.read<ConversationsCubit>().load(),
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    const SizedBox(height: 48),
                    Center(child: Text(l10n.chatConversationsEmpty)),
                  ],
                ),
              );
            }
            return RefreshIndicator(
              onRefresh: () => context.read<ConversationsCubit>().load(),
              child: ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                itemCount: state.items.length + (state.canLoadMore ? 1 : 0),
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, i) {
                  if (i == state.items.length) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: state.loadingMore
                            ? const CircularProgressIndicator()
                            : TextButton(
                                onPressed: () => context
                                    .read<ConversationsCubit>()
                                    .load(reset: false),
                                child: Text(l10n.friendsListLoadMore),
                              ),
                      ),
                    );
                  }
                  final c = state.items[i];
                  return _ConversationTile(conversation: c);
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  const _ConversationTile({required this.conversation});

  final DirectConversation conversation;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final last = conversation.lastMessage;
    final preview = last?.body?.trim().isNotEmpty == true
        ? last!.body!
        : (last != null && last.media.isNotEmpty ? '…' : '');
    return Card(
      child: ListTile(
        leading: ClipOval(
          child: SizedBox(
            width: 44,
            height: 44,
            child: buildUserAvatarImage(
              avatarUrl: null,
              size: 44,
              mediaRewriteContext: context,
            ),
          ),
        ),
        title: Text(
          conversation.peerUserId.length > 8
              ? '${conversation.peerUserId.substring(0, 8)}…'
              : conversation.peerUserId,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          preview.isEmpty ? l10n.chatPeerFallback : preview,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Text(
          conversation.lastActivityAt,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        onTap: () =>
            pushDirectChatPage(context, peerUserId: conversation.peerUserId),
      ),
    );
  }
}
