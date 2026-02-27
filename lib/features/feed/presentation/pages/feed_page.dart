import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import 'package:mobile_social_network/features/auth/domain/entities/user_entity.dart';
import 'package:mobile_social_network/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:mobile_social_network/features/auth/presentation/bloc/auth_state.dart';
import 'package:mobile_social_network/features/feed/presentation/cubit/feed_cubit.dart';
import 'package:mobile_social_network/features/feed/presentation/cubit/feed_state.dart';
import 'package:mobile_social_network/features/posts/domain/entities/note_entity.dart';
import 'package:mobile_social_network/features/posts/domain/repositories/note_repository.dart';
import 'package:mobile_social_network/features/posts/presentation/pages/edit_post_page.dart';
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
    context.read<FeedCubit>().loadNotes();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FeedCubit, FeedState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (state.pendingIds.isNotEmpty)
              _PublishingBar(count: state.pendingIds.length),
            Expanded(
              child: state.notes.isEmpty && state.pendingIds.isEmpty
                  ? const Center(child: Text('No posts yet'))
                  : ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: state.notes.length,
                      itemBuilder: (context, index) {
                        final note = state.notes[index];
                        final isPending =
                            note.id != null &&
                            state.pendingIds.contains(note.id);
                        final author = note.userId != null
                            ? state.authorByUserId[note.userId]
                            : null;
                        final authState = context.read<AuthBloc>().state;
                        final currentUserId = authState is AuthAuthenticated
                            ? authState.user.id
                            : null;
                        return _PostCard(
                          note: note,
                          author: author,
                          isPending: isPending,
                          isOwnPost: currentUserId != null &&
                              note.userId == currentUserId,
                          resolveImagePath: _resolveImagePath,
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}

Future<String?> _resolveImagePath(String? relativePath) async {
  if (relativePath == null || relativePath.isEmpty) return null;
  final dir = await getApplicationDocumentsDirectory();
  return path.join(dir.path, relativePath);
}

class _PublishingBar extends StatelessWidget {
  const _PublishingBar({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: 12),
              Text(
                count == 1 ? 'Publishing…' : 'Publishing $count…',
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
    required this.note,
    this.author,
    required this.isPending,
    required this.isOwnPost,
    required this.resolveImagePath,
  });

  final NoteEntity note;
  final UserEntity? author;
  final bool isPending;
  final bool isOwnPost;
  final Future<String?> Function(String?) resolveImagePath;

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
                            child: author!.avatarUrl != null
                                ? FutureBuilder<String?>(
                                    future: resolveImagePath(author!.avatarUrl),
                                    builder: (context, snapshot) {
                                      if (!snapshot.hasData ||
                                          snapshot.data == null) {
                                        return const Icon(
                                          Icons.person,
                                          size: 40,
                                        );
                                      }
                                      final file = File(snapshot.data!);
                                      if (!file.existsSync()) {
                                        return const Icon(
                                          Icons.person,
                                          size: 40,
                                        );
                                      }
                                      return Image.file(
                                        file,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) =>
                                            const Icon(Icons.person, size: 40),
                                      );
                                    },
                                  )
                                : const Icon(Icons.person, size: 30),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              author!.displayName?.isNotEmpty == true
                                  ? author!.displayName!
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
                              note.date,
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
                Text(note.note, style: Theme.of(context).textTheme.bodyLarge),

                // const SizedBox(height: 8),
                if (note.image != null) ...[
                  const SizedBox(height: 8),
                  FutureBuilder<String?>(
                    future: resolveImagePath(note.image),
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
                          builder: (context) => EditPostPage(note: note),
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
                          note.id != null &&
                          context.mounted) {
                        await context
                            .read<NoteRepository>()
                            .deleteNote(note.id!);
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

            if (isPending)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.surface.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 8),
                        Text('Publishing…'),
                      ],
                    ),
                  ),
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
