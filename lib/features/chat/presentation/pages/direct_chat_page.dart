import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import 'package:mobile_social_network/core/config/media_url_rewrite_config.dart';
import 'package:mobile_social_network/core/constants/media_upload_constants.dart';
import 'package:mobile_social_network/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:mobile_social_network/features/auth/presentation/bloc/auth_state.dart';
import 'package:mobile_social_network/features/chat/domain/entities/direct_message.dart';
import 'package:mobile_social_network/features/chat/domain/repositories/chat_repository.dart';
import 'package:mobile_social_network/features/chat/presentation/chat_navigation.dart';
import 'package:mobile_social_network/features/chat/presentation/cubit/direct_chat_cubit.dart';
import 'package:mobile_social_network/features/chat/presentation/cubit/direct_chat_state.dart';
import 'package:mobile_social_network/features/media/data/media_upload_service.dart';
import 'package:mobile_social_network/l10n/app_localizations.dart';

class DirectChatPage extends StatefulWidget {
  const DirectChatPage({
    super.key,
    required this.args,
  });

  final DirectChatRouteArgs args;

  @override
  State<DirectChatPage> createState() => _DirectChatPageState();
}

class _DirectChatPageState extends State<DirectChatPage> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    });
  }

  String _mapChatError(AppLocalizations l10n, String? code) {
    if (code == 'file_too_large') return l10n.chatErrorFileTooLarge;
    if (code == 'chat_media_type') return l10n.chatErrorMediaType;
    return code ?? '';
  }

  Future<void> _showAttachmentSheet(
    BuildContext context,
    DirectChatCubit cubit,
    AppLocalizations l10n,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                child: Text(
                  l10n.chatAttachSheetTitle,
                  style: Theme.of(ctx).textTheme.titleMedium,
                ),
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined),
                title: Text(l10n.chatAttachCamera),
                onTap: () {
                  Navigator.pop(ctx);
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      _takePhotoFromCamera(cubit);
                    }
                  });
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: Text(l10n.chatAttachGallery),
                onTap: () {
                  Navigator.pop(ctx);
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      _pickMediaFromGallery(cubit);
                    }
                  });
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickMediaFromGallery(DirectChatCubit cubit) async {
    final picker = ImagePicker();
    final list = await picker.pickMultipleMedia();
    if (list.isEmpty || !mounted) return;
    final max = MediaUploadConstants.maxMediaPerPost;
    final picked = list.map((x) => x.path).toList();
    final merged = [...cubit.state.pendingMediaPaths, ...picked]
        .take(max)
        .toList();
    cubit.setPendingMediaPaths(merged);
  }

  Future<void> _takePhotoFromCamera(DirectChatCubit cubit) async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );
    if (file == null || !mounted) return;
    final current = cubit.state.pendingMediaPaths;
    final max = MediaUploadConstants.maxMediaPerPost;
    if (current.length >= max) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.chatAttachLimitReached)),
      );
      return;
    }
    cubit.setPendingMediaPaths([...current, file.path]);
  }

  Future<void> _confirmBlock(
    BuildContext context,
    DirectChatCubit cubit,
    AppLocalizations l10n,
  ) async {
    final go = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.chatBlockConfirmTitle),
        content: Text(l10n.chatBlockConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(MaterialLocalizations.of(ctx).cancelButtonLabel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.chatBlockConfirmAction),
          ),
        ],
      ),
    );
    if (go == true && context.mounted) {
      final ok = await cubit.blockPeer();
      if (ok && context.mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final auth = context.read<AuthBloc>().state;
    if (auth is! AuthAuthenticated) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.chatOpenThread)),
        body: const Center(child: Text('Not signed in')),
      );
    }
    final title =
        widget.args.peerDisplayName?.trim().isNotEmpty == true
        ? widget.args.peerDisplayName!.trim()
        : widget.args.peerUserId;
    return BlocProvider(
      create: (_) => DirectChatCubit(
        repository: context.read<ChatRepository>(),
        mediaUploadService: context.read<MediaUploadService>(),
        peerUserId: widget.args.peerUserId,
        currentUserId: auth.user.id,
        peerDisplayName: widget.args.peerDisplayName,
      )..open(),
      child: BlocConsumer<DirectChatCubit, DirectChatState>(
        listenWhen: (a, b) =>
            a.lastError != b.lastError ||
            a.messages.length != b.messages.length,
        listener: (context, state) {
          if (state.lastError != null && context.mounted) {
            final msg = _mapChatError(l10n, state.lastError) != ''
                ? _mapChatError(l10n, state.lastError)
                : state.lastError!;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(msg)),
            );
            context.read<DirectChatCubit>().clearError();
          }
          if (state.messages.isNotEmpty) {
            _scrollToBottom();
          }
        },
        builder: (context, state) {
          final cubit = context.read<DirectChatCubit>();
          return Scaffold(
            appBar: AppBar(
              title: Text(title),
              actions: [
                PopupMenuButton<String>(
                  onSelected: (v) {
                    if (v == 'block') {
                      _confirmBlock(context, cubit, l10n);
                    }
                  },
                  itemBuilder: (ctx) => [
                    PopupMenuItem(
                      value: 'block',
                      child: Text(l10n.chatBlockUser),
                    ),
                  ],
                ),
              ],
            ),
            body: Column(
              children: [
                if (state.loading && state.messages.isEmpty)
                  const Expanded(
                    child: Center(child: CircularProgressIndicator()),
                  )
                else
                  Expanded(
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      itemCount:
                          state.messages.length +
                          (state.canLoadMoreOlder ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (state.canLoadMoreOlder && index == 0) {
                          return TextButton(
                            onPressed: state.loadingMore
                                ? null
                                : () => cubit.loadOlder(),
                            child: state.loadingMore
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(l10n.chatLoadOlder),
                          );
                        }
                        final i = state.canLoadMoreOlder ? index - 1 : index;
                        if (i < 0 || i >= state.messages.length) {
                          return const SizedBox.shrink();
                        }
                        final m = state.messages[i];
                        final mine = m.senderId == state.currentUserId;
                        return _MessageBubble(
                          message: m,
                          mine: mine,
                          onDelete: () => cubit.deleteMessage(m.messageId),
                          l10n: l10n,
                        );
                      },
                    ),
                  ),
                if (state.pendingMediaPaths.isNotEmpty)
                  SizedBox(
                    height: 72,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      itemCount: state.pendingMediaPaths.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, i) {
                        final p = state.pendingMediaPaths[i];
                        return Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                File(p),
                                width: 64,
                                height: 64,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  width: 64,
                                  height: 64,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.surfaceContainerHighest,
                                  child: const Icon(Icons.attach_file),
                                ),
                              ),
                            ),
                            Positioned(
                              right: 0,
                              top: 0,
                              child: IconButton(
                                icon: const Icon(Icons.close, size: 18),
                                onPressed: () {
                                  final next = List<String>.from(
                                    state.pendingMediaPaths,
                                  )..removeAt(i);
                                  cubit.setPendingMediaPaths(next);
                                },
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        IconButton(
                          tooltip: l10n.chatMediaAttach,
                          onPressed: state.sending
                              ? null
                              : () => _showAttachmentSheet(context, cubit, l10n),
                          icon: const Icon(Icons.attach_file_outlined),
                        ),
                        Expanded(
                          child: TextField(
                            controller: _textController,
                            minLines: 1,
                            maxLines: 5,
                            decoration: InputDecoration(
                              hintText: l10n.chatMessageHint,
                              border: const OutlineInputBorder(),
                              isDense: true,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        FilledButton(
                          onPressed: state.sending
                              ? null
                              : () async {
                                  final t = _textController.text;
                                  await cubit.sendText(t);
                                  _textController.clear();
                                },
                          child: Text(l10n.chatSend),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    required this.message,
    required this.mine,
    required this.onDelete,
    required this.l10n,
  });

  final DirectMessage message;
  final bool mine;
  final VoidCallback onDelete;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bg = mine ? scheme.primaryContainer : scheme.surfaceContainerHighest;
    final fg = mine ? scheme.onPrimaryContainer : scheme.onSurface;
    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.82,
        ),
        child: Card(
          color: bg,
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (message.media.isNotEmpty)
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: message.media.map((m) {
                      final ct = m.contentType ?? '';
                      if (ct.startsWith('image/') ||
                          m.url.toLowerCase().contains('.jpg') ||
                          m.url.toLowerCase().contains('.png') ||
                          m.url.toLowerCase().contains('.webp')) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Image.network(
                            context.resolveMediaDisplayUrl(m.url),
                            width: 120,
                            height: 120,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                const Icon(Icons.broken_image),
                          ),
                        );
                      }
                      return Icon(Icons.videocam_outlined, color: fg, size: 40);
                    }).toList(),
                  ),
                if (message.body != null && message.body!.trim().isNotEmpty)
                  SelectableText(
                    message.body!,
                    style: TextStyle(color: fg),
                  ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      message.createdAt,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: fg.withValues(alpha: 0.7),
                      ),
                    ),
                    const Spacer(),
                    PopupMenuButton<String>(
                      padding: EdgeInsets.zero,
                      child: Icon(Icons.more_horiz, size: 20, color: fg),
                      onSelected: (v) {
                        if (v == 'del') onDelete();
                      },
                      itemBuilder: (ctx) => [
                        PopupMenuItem(
                          value: 'del',
                          child: Text(l10n.chatDeleteMessage),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
