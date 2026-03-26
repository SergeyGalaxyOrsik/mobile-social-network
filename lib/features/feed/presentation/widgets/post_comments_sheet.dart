import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mobile_social_network/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:mobile_social_network/features/auth/presentation/bloc/auth_state.dart';
import 'package:mobile_social_network/features/feed/presentation/cubit/feed_cubit.dart';
import 'package:mobile_social_network/features/feed/presentation/cubit/post_comments_cubit.dart';
import 'package:mobile_social_network/features/feed/presentation/cubit/post_comments_state.dart';
import 'package:mobile_social_network/features/posts/domain/entities/comment_entity.dart';
import 'package:mobile_social_network/features/posts/domain/entities/post_entity.dart';
import 'package:mobile_social_network/features/posts/domain/repositories/post_engagement_repository.dart';
import 'package:mobile_social_network/l10n/app_localizations.dart';

String shortUserId(String id) {
  if (id.length <= 8) return id;
  return '${id.substring(0, 8)}…';
}

class PostCommentsSheet extends StatefulWidget {
  const PostCommentsSheet({super.key, required this.post});

  final PostEntity post;

  @override
  State<PostCommentsSheet> createState() => _PostCommentsSheetState();
}

class _PostCommentsSheetState extends State<PostCommentsSheet> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final postId = widget.post.postId;
    if (postId == null) {
      return const SizedBox.shrink();
    }

    final authState = context.read<AuthBloc>().state;
    final userId = authState is AuthAuthenticated ? authState.user.id : '';

    return BlocProvider(
      create: (context) => PostCommentsCubit(
        postId: postId,
        engagement: context.read<PostEngagementRepository>(),
        feedCubit: context.read<FeedCubit>(),
        currentUserId: userId,
      )..loadInitial(),
      child: _PostCommentsBody(controller: _controller, currentUserId: userId),
    );
  }
}

class _PostCommentsBody extends StatelessWidget {
  const _PostCommentsBody({
    required this.controller,
    required this.currentUserId,
  });

  final TextEditingController controller;
  final String currentUserId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final keyboard = MediaQuery.viewInsetsOf(context).bottom;

    return BlocListener<PostCommentsCubit, PostCommentsState>(
      listenWhen: (p, c) =>
          c.lastActionError != null && c.lastActionError != p.lastActionError,
      listener: (context, state) {
        final msg = state.lastActionError;
        if (msg != null && context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(msg)));
          context.read<PostCommentsCubit>().clearActionError();
        }
      },
      child: Padding(
        padding: EdgeInsets.only(bottom: keyboard),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                l10n.commentsTitle,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: BlocBuilder<PostCommentsCubit, PostCommentsState>(
                builder: (context, state) {
                  if (state.loadingInitial) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state.loadError != null) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Text(
                              state.loadError!,
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 12),
                          FilledButton(
                            onPressed: () =>
                                context.read<PostCommentsCubit>().loadInitial(),
                            child: Text(l10n.retry),
                          ),
                        ],
                      ),
                    );
                  }
                  if (state.comments.isEmpty) {
                    return Center(
                      child: Text(
                        l10n.noCommentsYet,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    );
                  }
                  return NotificationListener<ScrollNotification>(
                    onNotification: (n) {
                      if (n.metrics.pixels >= n.metrics.maxScrollExtent - 120) {
                        context.read<PostCommentsCubit>().loadMore();
                      }
                      return false;
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      itemCount:
                          state.comments.length + (state.loadingMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index >= state.comments.length) {
                          return const Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            ),
                          );
                        }
                        final c = state.comments[index];
                        return Builder(
                          builder: (itemContext) {
                            final liked = itemContext.select<FeedCubit, bool>(
                              (cubit) =>
                                  cubit.state.commentLikedByMe[c.commentId] ??
                                  false,
                            );
                            return _CommentTile(
                              comment: c,
                              liked: liked,
                              isOwn: c.userId == currentUserId,
                              onLike: () => itemContext
                                  .read<PostCommentsCubit>()
                                  .toggleCommentLike(c),
                              onDelete: () => itemContext
                                  .read<PostCommentsCubit>()
                                  .deleteComment(c),
                            );
                          },
                        );
                      },
                    ),
                  );
                },
              ),
            ),
            const Divider(height: 1),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controller,
                        minLines: 1,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: l10n.commentHint,
                          border: const OutlineInputBorder(),
                        ),
                        textCapitalization: TextCapitalization.sentences,
                      ),
                    ),
                    const SizedBox(width: 8),
                    BlocBuilder<PostCommentsCubit, PostCommentsState>(
                      buildWhen: (p, c) => p.sending != c.sending,
                      builder: (context, state) {
                        return FilledButton(
                          onPressed: state.sending
                              ? null
                              : () {
                                  final text = controller.text;
                                  context.read<PostCommentsCubit>().sendComment(
                                    text,
                                  );
                                  controller.clear();
                                },
                          child: state.sending
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(l10n.sendComment),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CommentTile extends StatelessWidget {
  const _CommentTile({
    required this.comment,
    required this.liked,
    required this.isOwn,
    required this.onLike,
    required this.onDelete,
  });

  final CommentEntity comment;
  final bool liked;
  final bool isOwn;
  final VoidCallback onLike;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final userLabel = comment.userId.isNotEmpty
        ? shortUserId(comment.userId)
        : l10n.commentUserShort;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userLabel,
                  style: Theme.of(
                    context,
                  ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  comment.content,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: l10n.likeTooltip,
            onPressed: onLike,
            icon: Icon(
              liked ? Icons.favorite : Icons.favorite_border,
              size: 22,
              color: liked
                  ? Theme.of(context).colorScheme.error
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              '${comment.likesCount}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          if (isOwn)
            IconButton(
              icon: Icon(
                Icons.delete_outline,
                color: Theme.of(context).colorScheme.error,
              ),
              onPressed: onDelete,
            ),
        ],
      ),
    );
  }
}
