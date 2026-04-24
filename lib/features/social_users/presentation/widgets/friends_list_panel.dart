import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mobile_social_network/core/utils/user_avatar.dart' show buildUserAvatarImage;
import 'package:mobile_social_network/features/social_users/domain/entities/friends_list_sort.dart';
import 'package:mobile_social_network/features/social_users/presentation/cubit/friends_list_cubit.dart';
import 'package:mobile_social_network/features/chat/presentation/chat_navigation.dart';
import 'package:mobile_social_network/features/social_users/presentation/cubit/friends_list_state.dart';
import 'package:mobile_social_network/features/social_users/presentation/pages/user_profile_page.dart';
import 'package:mobile_social_network/l10n/app_localizations.dart';

class FriendsListPanel extends StatefulWidget {
  const FriendsListPanel({super.key});

  @override
  State<FriendsListPanel> createState() => _FriendsListPanelState();
}

class _FriendsListPanelState extends State<FriendsListPanel> {
  final _qController = TextEditingController();
  final _prefixController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _qController.addListener(() => setState(() {}));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      context.read<FriendsListCubit>().load();
    });
  }

  @override
  void dispose() {
    _qController.dispose();
    _prefixController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocConsumer<FriendsListCubit, FriendsListState>(
      listenWhen: (a, b) => a.lastError != b.lastError,
      listener: (context, state) {
        if (state.lastError != null && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.lastError!)),
          );
          context.read<FriendsListCubit>().clearError();
        }
      },
      builder: (context, state) {
        final cubit = context.read<FriendsListCubit>();
        void applyFromFields() {
          cubit.setQuery(_qController.text);
          cubit.setUsernamePrefix(_prefixController.text);
          cubit.load();
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: TextField(
                controller: _qController,
                decoration: InputDecoration(
                  hintText: l10n.friendsListQueryHint,
                  border: const OutlineInputBorder(),
                  isDense: true,
                  suffixIcon: _qController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _qController.clear();
                            setState(() {});
                            cubit.setQuery('');
                            cubit.load();
                          },
                        )
                      : null,
                ),
                onChanged: (_) => setState(() {}),
                onSubmitted: (_) => applyFromFields(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _prefixController,
                decoration: InputDecoration(
                  hintText: l10n.friendsListUsernamePrefixHint,
                  border: const OutlineInputBorder(),
                  isDense: true,
                ),
                onSubmitted: (_) => applyFromFields(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: state.loading
                          ? null
                          : () async {
                              final d = await showDatePicker(
                                context: context,
                                initialDate: state.friendshipAfter ??
                                    DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime.now().add(
                                  const Duration(days: 365),
                                ),
                              );
                              if (d != null && context.mounted) {
                                cubit.setFriendshipAfter(d);
                              }
                            },
                      child: Text(
                        state.friendshipAfter == null
                            ? l10n.friendsListFriendshipAfter
                            : MaterialLocalizations.of(context)
                                .formatFullDate(
                                  state.friendshipAfter!,
                                ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: state.loading
                          ? null
                          : () async {
                              final d = await showDatePicker(
                                context: context,
                                initialDate: state.friendshipBefore ??
                                    DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime.now().add(
                                  const Duration(days: 365),
                                ),
                              );
                              if (d != null && context.mounted) {
                                cubit.setFriendshipBefore(d);
                              }
                            },
                      child: Text(
                        state.friendshipBefore == null
                            ? l10n.friendsListFriendshipBefore
                            : MaterialLocalizations.of(context)
                                .formatFullDate(
                                  state.friendshipBefore!,
                                ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<FriendsListSort>(
                      value: state.sort,
                      decoration: InputDecoration(
                        labelText: l10n.friendsListSortLabel,
                        border: const OutlineInputBorder(),
                        isDense: true,
                      ),
                      items: [
                        DropdownMenuItem(
                          value: FriendsListSort.relevance,
                          child: Text(l10n.friendsListSortRelevance),
                        ),
                        DropdownMenuItem(
                          value: FriendsListSort.usernameAsc,
                          child: Text(l10n.friendsListSortUsernameAsc),
                        ),
                        DropdownMenuItem(
                          value: FriendsListSort.usernameDesc,
                          child: Text(l10n.friendsListSortUsernameDesc),
                        ),
                        DropdownMenuItem(
                          value: FriendsListSort.friendshipCreatedAsc,
                          child: Text(l10n.friendsListSortFriendshipCreatedAsc),
                        ),
                        DropdownMenuItem(
                          value: FriendsListSort.friendshipCreatedDesc,
                          child: Text(
                            l10n.friendsListSortFriendshipCreatedDesc,
                          ),
                        ),
                      ],
                      onChanged: state.loading
                          ? null
                          : (v) {
                              if (v != null) {
                                cubit.setSort(v);
                              }
                            },
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Row(
                children: [
                  FilledButton(
                    onPressed: state.loading
                        ? null
                        : applyFromFields,
                    child: Text(l10n.friendsListApply),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton(
                    onPressed: state.loading
                        ? null
                        : () {
                            _qController.clear();
                            _prefixController.clear();
                            cubit.clearFilters();
                            cubit.load();
                          },
                    child: Text(l10n.friendsListClearFilters),
                  ),
                ],
              ),
            ),
            if (state.loading && state.items.isEmpty)
              const Expanded(
                child: Center(child: CircularProgressIndicator()),
              )
            else
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => cubit.load(),
                  child: state.items.isEmpty
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            const SizedBox(height: 48),
                            Center(child: Text(l10n.friendsListEmpty)),
                          ],
                        )
                      : ListView.separated(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
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
                                          onPressed: () => cubit.load(
                                            reset: false,
                                          ),
                                          child: Text(l10n.friendsListLoadMore),
                                        ),
                                ),
                              );
                            }
                            final f = state.items[i];
                            return Card(
                              child: ListTile(
                                leading: ClipOval(
                                  child: SizedBox(
                                    width: 40,
                                    height: 40,
                                    child: buildUserAvatarImage(
                                      avatarUrl: f.avatarUrl,
                                      size: 40,
                                      mediaRewriteContext: context,
                                    ),
                                  ),
                                ),
                                title: Text(f.username),
                                trailing: IconButton(
                                  tooltip: l10n.chatOpenThread,
                                  icon: const Icon(Icons.chat_bubble_outline),
                                  onPressed: () => pushDirectChatPage(
                                    context,
                                    peerUserId: f.userId,
                                    peerDisplayName: f.username,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (f.bio != null && f.bio!.isNotEmpty)
                                      Text(
                                        f.bio!,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    Text(
                                      f.friendshipCreatedAt,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurfaceVariant,
                                          ),
                                    ),
                                  ],
                                ),
                                onTap: () => pushUserProfilePage(
                                  context,
                                  f.userId,
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ),
          ],
        );
      },
    );
  }
}
