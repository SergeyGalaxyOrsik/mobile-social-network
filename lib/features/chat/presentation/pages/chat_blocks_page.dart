import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mobile_social_network/features/chat/domain/repositories/chat_repository.dart';
import 'package:mobile_social_network/features/chat/presentation/cubit/chat_blocks_cubit.dart';
import 'package:mobile_social_network/features/chat/presentation/cubit/chat_blocks_state.dart';
import 'package:mobile_social_network/l10n/app_localizations.dart';

class ChatBlocksPage extends StatelessWidget {
  const ChatBlocksPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocProvider(
      create: (_) => ChatBlocksCubit(context.read<ChatRepository>())..load(),
      child: Scaffold(
        appBar: AppBar(title: Text(l10n.chatBlockedUsersTitle)),
        body: BlocConsumer<ChatBlocksCubit, ChatBlocksState>(
          listenWhen: (a, b) => a.lastError != b.lastError,
          listener: (context, state) {
            if (state.lastError != null && context.mounted) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.lastError!)));
              context.read<ChatBlocksCubit>().clearError();
            }
          },
          builder: (context, state) {
            if (state.loading && state.items.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.items.isEmpty) {
              return RefreshIndicator(
                onRefresh: () => context.read<ChatBlocksCubit>().load(),
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    const SizedBox(height: 48),
                    Center(child: Text(l10n.chatBlocksEmpty)),
                  ],
                ),
              );
            }
            return RefreshIndicator(
              onRefresh: () => context.read<ChatBlocksCubit>().load(),
              child: ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                itemCount: state.items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, i) {
                  final b = state.items[i];
                  return Card(
                    child: ListTile(
                      title: Text(b.userId),
                      subtitle: Text(b.blockedAt),
                      trailing: TextButton(
                        onPressed: () =>
                            context.read<ChatBlocksCubit>().unblock(b.userId),
                        child: Text(l10n.chatUnblock),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
