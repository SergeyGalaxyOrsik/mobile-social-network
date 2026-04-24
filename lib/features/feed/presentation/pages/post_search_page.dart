import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mobile_social_network/core/share/post_share_helper.dart';
import 'package:mobile_social_network/core/utils/user_avatar.dart' show buildUserAvatarImage;
import 'package:mobile_social_network/features/feed/presentation/cubit/post_search_cubit.dart';
import 'package:mobile_social_network/features/feed/presentation/cubit/post_search_state.dart';
import 'package:mobile_social_network/features/feed/presentation/pages/feed_page.dart' show openPostCommentsSheet;
import 'package:mobile_social_network/features/posts/domain/entities/post_entity.dart';
import 'package:mobile_social_network/features/posts/domain/entities/post_search_sort.dart';
import 'package:mobile_social_network/features/posts/domain/entities/post_visibility.dart';
import 'package:mobile_social_network/features/social_users/presentation/pages/user_profile_page.dart';
import 'package:mobile_social_network/features/social_users/presentation/widgets/profile_post_tile.dart';
import 'package:mobile_social_network/l10n/app_localizations.dart';

class PostSearchPage extends StatefulWidget {
  const PostSearchPage({super.key});

  @override
  State<PostSearchPage> createState() => _PostSearchPageState();
}

class _PostSearchPageState extends State<PostSearchPage> {
  final _qController = TextEditingController();
  final _authorController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _qController.addListener(() => setState(() {}));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<PostSearchCubit>().load();
      }
    });
  }

  @override
  void dispose() {
    _qController.dispose();
    _authorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.postSearchTitle)),
      body: BlocConsumer<PostSearchCubit, PostSearchState>(
        listenWhen: (a, b) =>
            a.lastError != b.lastError || a.engagementError != b.engagementError,
        listener: (context, state) {
          if (state.lastError != null && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.lastError!)),
            );
            context.read<PostSearchCubit>().clearError();
          }
          final e = state.engagementError;
          if (e != null && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(e)),
            );
            context.read<PostSearchCubit>().clearEngagementError();
          }
        },
        builder: (context, state) {
          final cubit = context.read<PostSearchCubit>();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                child: TextField(
                  controller: _qController,
                  decoration: InputDecoration(
                    hintText: l10n.postSearchQueryHint,
                    border: const OutlineInputBorder(),
                    isDense: true,
                    suffixIcon: _qController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _qController.clear();
                              cubit.setQuery('');
                              cubit.load();
                            },
                          )
                        : null,
                  ),
                  onChanged: cubit.setQuery,
                  onSubmitted: (_) => _applySearch(cubit),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _authorController,
                  decoration: InputDecoration(
                    hintText: l10n.postSearchAuthorIdHint,
                    border: const OutlineInputBorder(),
                    isDense: true,
                  ),
                  onSubmitted: (_) => _applySearch(cubit),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<PostSearchSort?>(
                        value: state.sort,
                        decoration: InputDecoration(
                          labelText: l10n.postSearchSortLabel,
                          border: const OutlineInputBorder(),
                          isDense: true,
                        ),
                        items: [
                          DropdownMenuItem<PostSearchSort?>(
                            value: null,
                            child: Text(l10n.postSearchSortDefault),
                          ),
                          DropdownMenuItem(
                            value: PostSearchSort.relevance,
                            child: Text(l10n.postSearchSortRelevance),
                          ),
                          DropdownMenuItem(
                            value: PostSearchSort.createdAtDesc,
                            child: Text(l10n.postSearchSortCreatedDesc),
                          ),
                          DropdownMenuItem(
                            value: PostSearchSort.createdAtAsc,
                            child: Text(l10n.postSearchSortCreatedAsc),
                          ),
                          DropdownMenuItem(
                            value: PostSearchSort.likesDesc,
                            child: Text(l10n.postSearchSortLikesDesc),
                          ),
                          DropdownMenuItem(
                            value: PostSearchSort.commentsDesc,
                            child: Text(l10n.postSearchSortCommentsDesc),
                          ),
                        ],
                        onChanged: (v) {
                          cubit.setSort(v);
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField<PostVisibility?>(
                        value: state.visibility,
                        decoration: InputDecoration(
                          labelText: l10n.postSearchVisibilityLabel,
                          border: const OutlineInputBorder(),
                          isDense: true,
                        ),
                        items: [
                          DropdownMenuItem<PostVisibility?>(
                            value: null,
                            child: Text(l10n.postSearchVisibilityAny),
                          ),
                          DropdownMenuItem(
                            value: PostVisibility.public,
                            child: Text(l10n.postSearchVisibilityPublic),
                          ),
                          DropdownMenuItem(
                            value: PostVisibility.private,
                            child: Text(l10n.postSearchVisibilityPrivate),
                          ),
                          DropdownMenuItem(
                            value: PostVisibility.followers,
                            child: Text(l10n.postSearchVisibilityFollowers),
                          ),
                        ],
                        onChanged: cubit.setVisibility,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: FilledButton(
                  onPressed: state.loading ? null : () => _applySearch(cubit),
                  child: Text(l10n.friendsListApply),
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
                              Center(child: Text(l10n.postSearchEmpty)),
                            ],
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemCount: state.items.length + (state.canLoadMore ? 1 : 0),
                            separatorBuilder: (_, __) => const SizedBox(height: 12),
                            itemBuilder: (context, i) {
                              if (i == state.items.length) {
                                return Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: state.loadingMore
                                        ? const CircularProgressIndicator()
                                        : TextButton(
                                            onPressed: () =>
                                                cubit.load(reset: false),
                                            child: Text(l10n.friendsListLoadMore),
                                          ),
                                  ),
                                );
                              }
                              final post = state.items[i];
                              final id = post.postId;
                              final liked = id != null
                                  ? (state.postLikedByMe[id] ?? false)
                                  : false;
                              return _PostSearchResultTile(
                                post: post,
                                liked: liked,
                                onToggleLike: id != null
                                    ? () => cubit.togglePostLike(id)
                                    : null,
                                onOpenComments: id != null
                                    ? () => openPostCommentsSheet(context, post)
                                    : null,
                              );
                            },
                          ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  void _applySearch(PostSearchCubit cubit) {
    cubit.setQuery(_qController.text);
    cubit.setAuthorUserId(_authorController.text);
    cubit.load();
  }
}

class _PostSearchResultTile extends StatelessWidget {
  const _PostSearchResultTile({
    required this.post,
    required this.liked,
    this.onToggleLike,
    this.onOpenComments,
  });

  final PostEntity post;
  final bool liked;
  final VoidCallback? onToggleLike;
  final VoidCallback? onOpenComments;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final a = post.author;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (a != null && post.userId != null && post.userId!.isNotEmpty)
          InkWell(
            onTap: () => pushUserProfilePage(context, post.userId!),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  ClipOval(
                    child: SizedBox(
                      width: 40,
                      height: 40,
                      child: buildUserAvatarImage(
                        avatarUrl: a.avatarUrl,
                        size: 40,
                        mediaRewriteContext: context,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          a.username,
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ProfilePostTile(post: post),
        const SizedBox(height: 4),
        Row(
          children: [
            IconButton(
              tooltip: l10n.likeTooltip,
              onPressed: onToggleLike,
              icon: Icon(
                liked ? Icons.favorite : Icons.favorite_border,
                color: liked
                    ? Theme.of(context).colorScheme.error
                    : null,
              ),
            ),
            Text('${post.likesCount}'),
            const SizedBox(width: 8),
            IconButton(
              tooltip: l10n.commentsTooltip,
              onPressed: onOpenComments,
              icon: const Icon(Icons.chat_bubble_outline),
            ),
            Text('${post.commentsCount}'),
            const SizedBox(width: 4),
            IconButton(
              tooltip: l10n.postShareTooltip,
              onPressed: () => PostShareHelper.sharePost(
                context,
                post,
                l10n,
                resolveImagePath: resolvePostLocalMediaPath,
                shareAuthorLabel: post.author?.username,
              ),
              icon: Icon(
                Icons.share_outlined,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
