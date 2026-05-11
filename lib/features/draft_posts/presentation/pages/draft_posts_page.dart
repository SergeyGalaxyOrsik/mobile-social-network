import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mobile_social_network/features/draft_posts/domain/entities/draft_post.dart';
import 'package:mobile_social_network/features/draft_posts/domain/repositories/draft_posts_repository.dart';
import 'package:mobile_social_network/features/feed/presentation/cubit/feed_cubit.dart';
import 'package:mobile_social_network/features/posts/domain/entities/post_visibility.dart';

class DraftPostsPage extends StatefulWidget {
  const DraftPostsPage({super.key});

  @override
  State<DraftPostsPage> createState() => _DraftPostsPageState();
}

class _DraftPostsPageState extends State<DraftPostsPage> {
  bool _loading = true;
  String? _error;
  List<DraftPost> _items = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result = await context.read<DraftPostsRepository>().list();
      if (!mounted) return;
      setState(() {
        _items = result.items;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _createDraft() async {
    final controller = TextEditingController();
    final content = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New draft'),
        content: TextField(
          controller: controller,
          maxLines: 4,
          decoration: const InputDecoration(labelText: 'Content'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (content == null || content.isEmpty || !mounted) return;
    await context.read<DraftPostsRepository>().create(
      content: content,
      visibility: PostVisibility.public,
    );
    await _load();
  }

  Future<void> _delete(String draftId) async {
    await context.read<DraftPostsRepository>().delete(draftId);
    await _load();
  }

  Future<void> _publish(String draftId) async {
    await context.read<DraftPostsRepository>().publish(draftId);
    if (mounted) {
      context.read<FeedCubit>().refreshNotes();
    }
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Drafts'),
        actions: [
          IconButton(
            tooltip: 'Create draft',
            onPressed: _createDraft,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
            ? ListView(
                children: [
                  ListTile(
                    title: Text(_error!),
                    trailing: TextButton(
                      onPressed: _load,
                      child: const Text('Retry'),
                    ),
                  ),
                ],
              )
            : ListView.builder(
                itemCount: _items.length,
                itemBuilder: (context, index) {
                  final draft = _items[index];
                  return ListTile(
                    title: Text(
                      draft.content?.isNotEmpty == true
                          ? draft.content!
                          : '(empty draft)',
                    ),
                    subtitle: Text(draft.postCode ?? draft.draftId),
                    trailing: Wrap(
                      spacing: 4,
                      children: [
                        IconButton(
                          tooltip: 'Publish',
                          onPressed: () => _publish(draft.draftId),
                          icon: const Icon(Icons.publish_outlined),
                        ),
                        IconButton(
                          tooltip: 'Delete',
                          onPressed: () => _delete(draft.draftId),
                          icon: const Icon(Icons.delete_outline),
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}
