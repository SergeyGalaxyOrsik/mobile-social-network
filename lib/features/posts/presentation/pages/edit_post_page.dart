import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mobile_social_network/features/feed/presentation/cubit/feed_cubit.dart';
import 'package:mobile_social_network/features/posts/domain/entities/note_entity.dart';
import 'package:mobile_social_network/features/posts/domain/repositories/note_repository.dart';
import 'package:mobile_social_network/l10n/app_localizations.dart';

import '../widgets/create_post_input_widget.dart';

const int _kMaxPostLength = 280;

class EditPostPage extends StatefulWidget {
  const EditPostPage({super.key, required this.note});

  final NoteEntity note;

  @override
  State<EditPostPage> createState() => _EditPostPageState();
}

class _EditPostPageState extends State<EditPostPage> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.note.note);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onSave() async {
    final text = _controller.text.trim();
    if (text.isEmpty || text.length > _kMaxPostLength) return;

    final note = widget.note;
    if (note.id == null) return;

    final updated = NoteEntity(
      id: note.id,
      userId: note.userId,
      note: text,
      date: note.date,
      image: note.image,
    );

    final noteRepository = context.read<NoteRepository>();
    final feedCubit = context.read<FeedCubit>();

    await noteRepository.updateNote(updated);
    await feedCubit.loadNotes();

    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.editPostTitle),
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
              onPressed: _onSave,
              child: Text(
                l10n.saveChanges,
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
          CreatePostInput(
            controller: _controller,
            maxLength: _kMaxPostLength,
            hintText: l10n.createPostPlaceholder,
            charCountLabel: l10n.createPostCharCount,
            onChanged: (_) => setState(() {}),
          ),
        ],
      ),
    );
  }
}
