import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_social_network/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:mobile_social_network/features/auth/presentation/bloc/auth_state.dart';
import 'package:mobile_social_network/core/utils/ascii_image.dart';
import 'package:mobile_social_network/core/utils/post_image_storage.dart';
import 'package:mobile_social_network/features/feed/presentation/cubit/feed_cubit.dart';
import 'package:mobile_social_network/features/posts/domain/entities/note_entity.dart';
import 'package:mobile_social_network/features/posts/domain/repositories/note_repository.dart';
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
  XFile? _selectedImage;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final xFile = await picker.pickImage(source: ImageSource.gallery);
    if (xFile != null && mounted) {
      setState(() => _selectedImage = xFile);
    }
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
    final text = _controller.text.trim();
    if (text.isEmpty || text.length > _kMaxPostLength) return;

    final noteRepository = context.read<NoteRepository>();
    final feedCubit = context.read<FeedCubit>();

    final date = DateTime.now().toIso8601String();
    final entity = NoteEntity(note: text, date: date, image: null);
    final id = await noteRepository.createNote(entity);

    await feedCubit.loadNotes();
    final hadImage = _selectedImage != null;
    final imagePath = _selectedImage?.path;
    if (hadImage) {
      feedCubit.addPending(id);
    }

    if (!mounted) return;
    Navigator.of(context).pop();

    if (hadImage && imagePath != null) {
      Future(() async {
        try {
          final bytes = await File(imagePath).readAsBytes();
          final pngBytes = await imageToAsciiPng(bytes);
          final relativePath = await savePostImage(id, pngBytes);
          await noteRepository.updateNote(
            NoteEntity(id: id, note: text, date: date, image: relativePath),
          );
          feedCubit.removePending(id);
          await feedCubit.loadNotes();
        } catch (_) {
          feedCubit.removePending(id);
          await feedCubit.loadNotes();
        }
      });
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
              onPressed: _onPost,
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
          _UploadPhotoArea(
            selectedImagePath: _selectedImage?.path,
            uploadLabel: l10n.uploadMedia,
            onTap: _pickImage,
            onRemove: _selectedImage != null
                ? () => setState(() => _selectedImage = null)
                : null,
          ),
        ],
      ),
    );
  }
}

class _UploadPhotoArea extends StatelessWidget {
  const _UploadPhotoArea({
    this.selectedImagePath,
    required this.uploadLabel,
    required this.onTap,
    this.onRemove,
  });

  final String? selectedImagePath;
  final String uploadLabel;
  final VoidCallback onTap;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.sizeOf(context);
    const double areaHeight = 160;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Material(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            height: areaHeight,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: theme.colorScheme.outline),
            ),
            clipBehavior: Clip.antiAlias,
            child: selectedImagePath != null
                ? Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.file(File(selectedImagePath!), fit: BoxFit.cover),
                      if (onRemove != null)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: IconButton.filled(
                            icon: const Icon(Icons.close, size: 20),
                            onPressed: onRemove,
                            style: IconButton.styleFrom(
                              backgroundColor: theme.colorScheme.surface
                                  .withValues(alpha: 0.9),
                              foregroundColor: theme.colorScheme.onSurface,
                            ),
                          ),
                        ),
                    ],
                  )
                : CustomPaint(
                    size: Size(size.width - 32, areaHeight),
                    painter: _DottedBackgroundPainter(
                      color: theme.colorScheme.outline.withValues(alpha: 0.2),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.add_a_photo,
                            size: 48,
                            color: theme.colorScheme.onSurface,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            uploadLabel.toUpperCase(),
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: theme.colorScheme.onSurface,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

class _DottedBackgroundPainter extends CustomPainter {
  _DottedBackgroundPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    const double spacing = 12;
    const double radius = 1.5;
    for (double x = spacing; x < size.width; x += spacing) {
      for (double y = spacing; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), radius, Paint()..color = color);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
