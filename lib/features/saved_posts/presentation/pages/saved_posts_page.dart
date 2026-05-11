import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mobile_social_network/features/custom_tags/domain/entities/custom_tag.dart';
import 'package:mobile_social_network/features/custom_tags/domain/repositories/custom_tags_repository.dart';
import 'package:mobile_social_network/features/saved_posts/domain/entities/saved_post.dart';
import 'package:mobile_social_network/features/saved_posts/domain/repositories/saved_posts_repository.dart';

class SavedPostsPage extends StatefulWidget {
  const SavedPostsPage({super.key});

  @override
  State<SavedPostsPage> createState() => _SavedPostsPageState();
}

class _SavedPostsPageState extends State<SavedPostsPage> {
  bool _loading = true;
  String? _error;
  List<SavedPost> _posts = const [];
  List<CustomTag> _tags = const [];

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
      final results = await Future.wait<Object>([
        context.read<SavedPostsRepository>().list(),
        context.read<CustomTagsRepository>().list(),
      ]);
      if (!mounted) return;
      setState(() {
        _posts = (results[0] as ({List<SavedPost> items, int total})).items;
        _tags = (results[1] as ({List<CustomTag> items, int total})).items;
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

  Future<void> _createTag() async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New tag'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('Create'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (name == null || name.isEmpty || !mounted) return;
    await context.read<CustomTagsRepository>().create(name);
    await _load();
  }

  Future<void> _removePost(String postId) async {
    await context.read<SavedPostsRepository>().remove(postId);
    await _load();
  }

  Future<void> _toggleTag(SavedPost saved, CustomTag tag) async {
    final postId = saved.post.postId;
    if (postId == null) return;
    final hasTag = saved.tags.any((e) => e.tagId == tag.tagId);
    if (hasTag) {
      await context.read<SavedPostsRepository>().removeTag(postId, tag.tagId);
    } else {
      await context.read<SavedPostsRepository>().addTag(postId, tag.tagId);
    }
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved posts'),
        actions: [
          IconButton(
            tooltip: 'New tag',
            onPressed: _createTag,
            icon: const Icon(Icons.new_label_outlined),
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
                itemCount: _posts.length,
                itemBuilder: (context, index) {
                  final saved = _posts[index];
                  final postId = saved.post.postId;
                  return ExpansionTile(
                    title: Text(saved.post.content),
                    subtitle: Text(saved.savedAt ?? postId ?? ''),
                    trailing: postId == null
                        ? null
                        : IconButton(
                            tooltip: 'Remove',
                            onPressed: () => _removePost(postId),
                            icon: const Icon(Icons.bookmark_remove),
                          ),
                    children: [
                      if (_tags.isEmpty)
                        const ListTile(title: Text('No custom tags yet')),
                      for (final tag in _tags)
                        CheckboxListTile(
                          value: saved.tags.any((e) => e.tagId == tag.tagId),
                          title: Text(tag.name),
                          onChanged: (_) => _toggleTag(saved, tag),
                        ),
                    ],
                  );
                },
              ),
      ),
    );
  }
}
