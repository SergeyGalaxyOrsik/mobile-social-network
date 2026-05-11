import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mobile_social_network/features/social_users/domain/entities/friend_request_item.dart';
import 'package:mobile_social_network/features/social_users/presentation/cubit/friend_requests_cubit.dart';
import 'package:mobile_social_network/features/social_users/presentation/cubit/friend_requests_state.dart';
import 'package:mobile_social_network/features/social_users/presentation/widgets/friends_list_panel.dart';
import 'package:mobile_social_network/features/social_users/presentation/widgets/user_search_panel.dart';
import 'package:mobile_social_network/l10n/app_localizations.dart';

/// Вкладка «Друзья»: поиск людей, входящие и исходящие заявки.
class FriendsTabPage extends StatefulWidget {
  const FriendsTabPage({
    super.key,
    this.initialFriendsTabIndex = 0,
    this.highlightIncomingRequestId,
  });

  /// 0 — поиск людей, 1 — мои друзья, 2 — входящие, 3 — исходящие.
  final int initialFriendsTabIndex;
  final String? highlightIncomingRequestId;

  @override
  State<FriendsTabPage> createState() => _FriendsTabPageState();
}

class _FriendsTabPageState extends State<FriendsTabPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 4,
      vsync: this,
      initialIndex: widget.initialFriendsTabIndex.clamp(0, 3),
    );
  }

  @override
  void didUpdateWidget(FriendsTabPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialFriendsTabIndex != oldWidget.initialFriendsTabIndex) {
      _tabController.animateTo(widget.initialFriendsTabIndex.clamp(0, 3));
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.mainNavFriends),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: l10n.friendRequestsSearchTab),
            Tab(text: l10n.friendListTab),
            Tab(text: l10n.friendRequestsIncomingTab),
            Tab(text: l10n.friendRequestsOutgoingTab),
          ],
        ),
      ),
      body: BlocConsumer<FriendRequestsCubit, FriendRequestsState>(
        listener: (context, state) {
          final err = state.lastError;
          if (err != null && context.mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(err)));
            context.read<FriendRequestsCubit>().clearError();
          }
        },
        builder: (context, state) {
          if (state.loading &&
              state.incoming.isEmpty &&
              state.outgoing.isEmpty) {
            return TabBarView(
              controller: _tabController,
              children: const [
                UserSearchPanel(),
                FriendsListPanel(),
                Center(child: CircularProgressIndicator()),
                Center(child: CircularProgressIndicator()),
              ],
            );
          }
          return TabBarView(
            controller: _tabController,
            children: [
              const UserSearchPanel(),
              const FriendsListPanel(),
              _RequestList(
                emptyLabel: l10n.friendRequestsEmptyIncoming,
                items: state.incoming,
                incoming: true,
                processingId: state.processingRequestId,
                highlightRequestId: widget.highlightIncomingRequestId,
              ),
              _RequestList(
                emptyLabel: l10n.friendRequestsEmptyOutgoing,
                items: state.outgoing,
                incoming: false,
                processingId: state.processingRequestId,
                highlightRequestId: null,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _RequestList extends StatelessWidget {
  const _RequestList({
    required this.emptyLabel,
    required this.items,
    required this.incoming,
    required this.processingId,
    this.highlightRequestId,
  });

  final String emptyLabel;
  final List<FriendRequestItem> items;
  final bool incoming;
  final String? processingId;
  final String? highlightRequestId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cubit = context.read<FriendRequestsCubit>();
    if (items.isEmpty) {
      return Center(child: Text(emptyLabel));
    }
    return RefreshIndicator(
      onRefresh: cubit.load,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final item = items[index];
          final busy = processingId == item.requestId;
          final highlight =
              incoming &&
              highlightRequestId != null &&
              highlightRequestId == item.requestId;
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: highlight
                  ? BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                      width: 2,
                    )
                  : BorderSide.none,
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.peerUsername,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.createdAt,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (incoming)
                    Row(
                      children: [
                        FilledButton(
                          onPressed: busy
                              ? null
                              : () => cubit.accept(item.requestId),
                          child: Text(l10n.friendRequestsAccept),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton(
                          onPressed: busy
                              ? null
                              : () => cubit.decline(item.requestId),
                          child: Text(l10n.friendRequestsDecline),
                        ),
                      ],
                    )
                  else
                    OutlinedButton(
                      onPressed: busy
                          ? null
                          : () => cubit.cancelOutgoing(item.requestId),
                      child: Text(l10n.friendRequestsCancel),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
