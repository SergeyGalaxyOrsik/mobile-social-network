import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_social_network/core/config/media_url_rewrite_config.dart';
import 'package:mobile_social_network/core/share/post_share_helper.dart';
import 'package:mobile_social_network/features/auth/domain/entities/user_entity.dart';
import 'package:mobile_social_network/core/utils/user_avatar.dart';
import 'package:mobile_social_network/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:mobile_social_network/features/auth/presentation/bloc/auth_state.dart';
import 'package:mobile_social_network/features/feed/presentation/cubit/feed_cubit.dart';
import 'package:mobile_social_network/features/feed/presentation/cubit/feed_state.dart';
import 'package:mobile_social_network/features/feed/presentation/cubit/post_search_cubit.dart';
import 'package:mobile_social_network/features/feed/presentation/pages/post_search_page.dart';
import 'package:mobile_social_network/features/posts/domain/repositories/post_engagement_repository.dart';
import 'package:mobile_social_network/features/feed/presentation/widgets/post_comments_sheet.dart';
import 'package:mobile_social_network/features/posts/domain/entities/post_entity.dart';
import 'package:mobile_social_network/features/posts/domain/entities/post_media_item.dart';
import 'package:mobile_social_network/features/posts/domain/repositories/post_repository.dart';
import 'package:mobile_social_network/features/posts/presentation/pages/edit_post_page.dart';
import 'package:mobile_social_network/features/social_users/presentation/pages/user_profile_page.dart';
import 'package:mobile_social_network/l10n/app_localizations.dart';

class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final authState = context.read<AuthBloc>().state;
      final user = authState is AuthAuthenticated ? authState.user : null;
      context.read<FeedCubit>().loadNotes(currentUser: user);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<FeedCubit, FeedState>(
      listenWhen: (prev, curr) =>
          curr.lastPublishError != null &&
          curr.lastPublishError != prev.lastPublishError,
      listener: (context, state) {
        final msg = state.lastPublishError;
        if (msg != null && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
          context.read<FeedCubit>().clearPublishError();
        }
      },
      child: BlocListener<FeedCubit, FeedState>(
        listenWhen: (prev, curr) =>
            curr.lastEngagementError != null &&
            curr.lastEngagementError != prev.lastEngagementError,
        listener: (context, state) {
          final msg = state.lastEngagementError;
          if (msg != null && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
            context.read<FeedCubit>().clearEngagementError();
          }
        },
        child: BlocBuilder<FeedCubit, FeedState>(
          builder: (context, state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    tooltip: AppLocalizations.of(context)!.feedSearchPostsTooltip,
                    icon: const Icon(Icons.search),
                    onPressed: () {
                      final postRepo = context.read<PostRepository>();
                      final engagement =
                          context.read<PostEngagementRepository>();
                      Navigator.of(context).push<void>(
                        MaterialPageRoute<void>(
                          builder: (_) => BlocProvider<PostSearchCubit>(
                            create: (_) => PostSearchCubit(
                              postRepository: postRepo,
                              postEngagement: engagement,
                            ),
                            child: const PostSearchPage(),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                if (state.publishingTasks.isNotEmpty)
                  _PublishingBar(
                    taskCount: state.publishingTasks.length,
                    progress: state.aggregatePublishProgress,
                  ),
                Expanded(
                  child: state.posts.isEmpty && state.publishingTasks.isEmpty
                      ? const Center(child: Text('No posts yet'))
                      : ListView.builder(
                          padding: EdgeInsets.zero,
                          itemCount: state.posts.length,
                          itemBuilder: (context, index) {
                            final post = state.posts[index];
                            final author = post.userId != null
                                ? state.authorByUserId[post.userId]
                                : null;
                            final authState = context.read<AuthBloc>().state;
                            final currentUserId = authState is AuthAuthenticated
                                ? authState.user.id
                                : null;
                            final postId = post.postId;
                            return _PostCard(
                              post: post,
                              author: author,
                              isOwnPost: currentUserId != null &&
                                  post.userId == currentUserId,
                              resolveImagePath: _resolveImagePath,
                              postLiked: postId != null
                                  ? (state.postLikedByMe[postId] ?? false)
                                  : false,
                              onToggleLike: postId != null
                                  ? () => context
                                      .read<FeedCubit>()
                                      .togglePostLike(postId)
                                  : null,
                              onOpenComments: postId != null
                                  ? () => openPostCommentsSheet(context, post)
                                  : null,
                            );
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

void openPostCommentsSheet(BuildContext context, PostEntity post) {
  final height = MediaQuery.sizeOf(context).height * 0.65;
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: false,
    builder: (ctx) => SizedBox(
      height: height,
      child: PostCommentsSheet(post: post),
    ),
  );
}

Future<String?> _resolveImagePath(String? relativePath) =>
    resolvePostLocalMediaPath(relativePath);

class _PostMediaBlock extends StatelessWidget {
  const _PostMediaBlock({
    required this.media,
    required this.resolveImagePath,
  });

  final PostMediaItem media;
  final Future<String?> Function(String?) resolveImagePath;

  @override
  Widget build(BuildContext context) {
    if (media.type.startsWith('image/')) {
      final rel = media.localRelativePath;
      if (rel != null && rel.isNotEmpty) {
        return FutureBuilder<String?>(
          future: resolveImagePath(rel),
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data != null) {
              final file = File(snapshot.data!);
              if (file.existsSync()) {
                return GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (context) => _FullScreenPhotoPage(
                          imagePath: snapshot.data!,
                        ),
                      ),
                    );
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      file,
                      fit: BoxFit.contain,
                      width: double.infinity,
                      height: 300,
                      errorBuilder: (_, __, ___) =>
                          _networkImageTile(context, media.url),
                    ),
                  ),
                );
              }
            }
            return _networkImageTile(context, media.url);
          },
        );
      }
      return _networkImageTile(context, media.url);
    }
    if (media.type.startsWith('video/')) {
      return Container(
        height: 160,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Theme.of(context).colorScheme.outline),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.play_circle_outline,
              size: 48,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 12),
            Text('Video', style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }
}

Widget _networkImageTile(BuildContext context, String url) {
  final resolved = context.resolveMediaDisplayUrl(url);
  return GestureDetector(
    onTap: () {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (context) => _FullScreenNetworkPhotoPage(url: resolved),
        ),
      );
    },
    child: ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        resolved,
        fit: BoxFit.contain,
        width: double.infinity,
        height: 300,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return SizedBox(
            height: 200,
            child: Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
              ),
            ),
          );
        },
        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
      ),
    ),
  );
}

class _FullScreenNetworkPhotoPage extends StatelessWidget {
  const _FullScreenNetworkPhotoPage({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 4,
              child: Image.network(
                url,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Center(
                  child: Text(
                    'Failed to load image',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 28),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PublishingBar extends StatelessWidget {
  const _PublishingBar({
    required this.taskCount,
    required this.progress,
  });

  final int taskCount;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  minHeight: 4,
                  value: progress.clamp(0.0, 1.0),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                taskCount <= 1
                    ? 'Publishing…'
                    : 'Publishing ($taskCount)…',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PostCard extends StatelessWidget {
  const _PostCard({
    required this.post,
    this.author,
    required this.isOwnPost,
    required this.resolveImagePath,
    required this.postLiked,
    this.onToggleLike,
    this.onOpenComments,
  });

  final PostEntity post;
  final UserEntity? author;
  final bool isOwnPost;
  final Future<String?> Function(String?) resolveImagePath;
  final bool postLiked;
  final VoidCallback? onToggleLike;
  final VoidCallback? onOpenComments;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final side = BorderSide(
      color: Theme.of(context).colorScheme.outline,
      width: 2,
    );
    return Container(
      decoration: BoxDecoration(border: Border(bottom: side)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (author != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: InkWell(
                      onTap: post.userId != null && post.userId!.isNotEmpty
                          ? () => pushUserProfilePage(context, post.userId!)
                          : null,
                      child: Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Theme.of(context).colorScheme.outline,
                              ),
                            ),
                            child: SizedBox(
                              width: 40,
                              height: 40,
                              child: buildUserAvatarImage(
                                avatarUrl: author!.avatarUrl,
                                size: 40,
                                mediaRewriteContext: context,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                author!.username?.isNotEmpty == true
                                    ? author!.username!
                                    : author!.email,
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                              Text(
                                post.createdAt,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                                    ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                Text(post.content, style: Theme.of(context).textTheme.bodyLarge),

                if (post.media != null && post.media!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  ...post.media!.map(
                    (m) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _PostMediaBlock(
                        media: m,
                        resolveImagePath: resolveImagePath,
                      ),
                    ),
                  ),
                ] else if (post.image != null) ...[
                  const SizedBox(height: 8),
                  FutureBuilder<String?>(
                    future: resolveImagePath(post.image),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData || snapshot.data == null) {
                        return const SizedBox.shrink();
                      }
                      final file = File(snapshot.data!);
                      if (!file.existsSync()) {
                        return const SizedBox.shrink();
                      }
                      final imagePath = snapshot.data!;
                      return GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (context) =>
                                  _FullScreenPhotoPage(imagePath: imagePath),
                            ),
                          );
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            file,
                            fit: BoxFit.contain,
                            width: double.infinity,
                            height: 300,
                            errorBuilder: (_, __, ___) =>
                                const SizedBox.shrink(),
                          ),
                        ),
                      );
                    },
                  ),
                ],
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (post.postId != null) ...[
                      IconButton(
                        tooltip: l10n.likeTooltip,
                        onPressed: onToggleLike,
                        icon: Icon(
                          postLiked ? Icons.favorite : Icons.favorite_border,
                          color: postLiked
                              ? Theme.of(context).colorScheme.error
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        '${post.likesCount}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        tooltip: l10n.commentsTooltip,
                        onPressed: onOpenComments,
                        icon: Icon(
                          Icons.chat_bubble_outline,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        '${post.commentsCount}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(width: 4),
                    ],
                    IconButton(
                      tooltip: l10n.postShareTooltip,
                      onPressed: () => PostShareHelper.sharePost(
                        context,
                        post,
                        l10n,
                        resolveImagePath: resolveImagePath,
                        shareAuthorLabel: author != null
                            ? (author!.username?.isNotEmpty == true
                                ? author!.username
                                : author!.email)
                            : post.author?.username,
                      ),
                      icon: Icon(
                        Icons.share_outlined,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            if (isOwnPost)
              Positioned(
                top: 0,
                right: 0,
                child: PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_vert,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  onSelected: (value) async {
                    if (value == 'edit') {
                      await Navigator.of(context).push<void>(
                        MaterialPageRoute(
                          builder: (context) => EditPostPage(post: post),
                        ),
                      );
                      if (context.mounted) {
                        context.read<FeedCubit>().loadNotes();
                      }
                    } else if (value == 'delete') {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: Text(l10n.deletePostConfirmTitle),
                          content: Text(l10n.deletePostConfirmMessage),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(false),
                              child: Text(l10n.cancel),
                            ),
                            FilledButton(
                              onPressed: () => Navigator.of(ctx).pop(true),
                              child: Text(l10n.deletePost),
                            ),
                          ],
                        ),
                      );
                      if (confirmed == true &&
                          post.localId != null &&
                          context.mounted) {
                        await context
                            .read<PostRepository>()
                            .deletePost(post.localId!);
                        if (context.mounted) {
                          context.read<FeedCubit>().loadNotes();
                        }
                      }
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          const Icon(Icons.edit_outlined),
                          const SizedBox(width: 8),
                          Text(l10n.editPost),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(
                            Icons.delete_outline,
                            color: Theme.of(context).colorScheme.error,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            l10n.deletePost,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

          ],
        ),
      ),
    );
  }
}

class _FullScreenPhotoPage extends StatelessWidget {
  const _FullScreenPhotoPage({required this.imagePath});

  final String imagePath;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 4,
              child: Image.file(
                File(imagePath),
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Center(
                  child: Text(
                    'Failed to load image',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 28),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
