import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:mobile_social_network/core/constants/media_upload_constants.dart';
import 'package:mobile_social_network/core/utils/prepublish_image_filter.dart';
import 'package:mobile_social_network/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:mobile_social_network/features/auth/presentation/bloc/auth_state.dart';
import 'package:mobile_social_network/features/feed/presentation/cubit/feed_cubit.dart';
import 'package:mobile_social_network/features/feed/presentation/cubit/publish_attachment.dart';
import 'package:mobile_social_network/features/posts/domain/entities/post_visibility.dart';
import 'package:mobile_social_network/l10n/app_localizations.dart';

import '../widgets/create_post_input_widget.dart';
import '../widgets/own_profile_widget.dart';

const int _kMaxPostLength = 280;

class CreatePostPage extends StatefulWidget {
  const CreatePostPage({super.key});

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  late final TextEditingController _controller;
  final List<XFile> _selectedFiles = [];
  bool _isPublishing = false;

  Future<void> _pickMedia() async {
    final picker = ImagePicker();
    final list = await picker.pickMultipleMedia();
    if (list.isEmpty || !mounted) return;
    setState(() {
      _selectedFiles
        ..clear()
        ..addAll(
          list.take(MediaUploadConstants.maxMediaPerPost),
        );
    });
  }

  void _removeAt(int index) {
    setState(() => _selectedFiles.removeAt(index));
  }

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onPost() async {
    if (_isPublishing) return;
    final text = _controller.text.trim();
    if (text.isEmpty || text.length > _kMaxPostLength) return;

    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;
    final userId = authState.user.id;

    setState(() => _isPublishing = true);
    try {
      final attachments = <PublishAttachment>[];
      for (final x in _selectedFiles) {
        final uploadPath = await prepareImagePathForPublish(x.path);
        final f = File(uploadPath);
        final size = await f.length();
        if (size > MediaUploadConstants.maxFileBytes) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('File too large')),
          );
          return;
        }
        final mime =
            lookupMimeType(uploadPath) ?? 'application/octet-stream';
        attachments.add(
          PublishAttachment(
            path: uploadPath,
            contentType: mime,
            sizeBytes: size,
          ),
        );
      }

      if (!mounted) return;
      context.read<FeedCubit>().enqueuePublish(
        userId: userId,
        content: text,
        visibility: PostVisibility.public,
        attachments: attachments,
      );

      if (!mounted) return;
      Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _isPublishing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.createPost),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: TextButton(
              style: TextButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
                backgroundColor: Theme.of(context).colorScheme.primary,
              ),
              onPressed: _isPublishing ? null : _onPost,
              child: Text(
                l10n.postButton,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.surface,
                    ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Divider(height: 2, color: Theme.of(context).colorScheme.outline),
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              if (state is! AuthAuthenticated) return const SizedBox.shrink();
              return OwnProfileWidget(user: state.user);
            },
          ),
          Divider(height: 2, color: Theme.of(context).colorScheme.outline),
          CreatePostInput(
            controller: _controller,
            maxLength: _kMaxPostLength,
            hintText: l10n.createPostPlaceholder,
            charCountLabel: l10n.createPostCharCount,
            onChanged: (_) => setState(() {}),
          ),
          Divider(height: 2, color: Theme.of(context).colorScheme.outline),
          _MediaPickerStrip(
            files: _selectedFiles,
            uploadLabel: l10n.uploadMedia,
            onAdd: _pickMedia,
            onRemove: _removeAt,
          ),
        ],
      ),
    );
  }
}

class _MediaPickerStrip extends StatelessWidget {
  const _MediaPickerStrip({
    required this.files,
    required this.uploadLabel,
    required this.onAdd,
    required this.onRemove,
  });

  final List<XFile> files;
  final String uploadLabel;
  final VoidCallback onAdd;
  final void Function(int index) onRemove;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        scrollDirection: Axis.horizontal,
        children: [
          _AddTile(label: uploadLabel, onTap: onAdd),
          for (var i = 0; i < files.length; i++)
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: _ThumbTile(
                file: files[i],
                onRemove: () => onRemove(i),
              ),
            ),
        ],
      ),
    );
  }
}

class _AddTile extends StatelessWidget {
  const _AddTile({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 120,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: theme.colorScheme.outline),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_a_photo, color: theme.colorScheme.onSurface),
              const SizedBox(height: 8),
              Text(
                label.toUpperCase(),
                textAlign: TextAlign.center,
                style: theme.textTheme.labelSmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ThumbTile extends StatelessWidget {
  const _ThumbTile({required this.file, required this.onRemove});

  final XFile file;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mime = lookupMimeType(file.path) ?? '';
    final isVideo = mime.startsWith('video/');

    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: 120,
            height: 140,
            color: theme.colorScheme.surfaceContainerHighest,
            child: isVideo
                ? Center(
                    child: Icon(
                      Icons.videocam,
                      size: 48,
                      color: theme.colorScheme.onSurface,
                    ),
                  )
                : Image.file(
                    File(file.path),
                    fit: BoxFit.cover,
                    width: 120,
                    height: 140,
                  ),
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: IconButton.filled(
            icon: const Icon(Icons.close, size: 18),
            onPressed: onRemove,
            style: IconButton.styleFrom(
              backgroundColor:
                  theme.colorScheme.surface.withValues(alpha: 0.9),
              foregroundColor: theme.colorScheme.onSurface,
              padding: EdgeInsets.zero,
              minimumSize: const Size(28, 28),
            ),
          ),
        ),
      ],
    );
  }
}
