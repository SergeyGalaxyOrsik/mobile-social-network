import 'package:mobile_social_network/features/custom_tags/domain/entities/custom_tag.dart';
import 'package:mobile_social_network/features/posts/data/mappers/post_response_dto_mapper.dart';
import 'package:mobile_social_network/features/saved_posts/data/datasources/saved_posts_remote_datasource.dart';
import 'package:mobile_social_network/features/saved_posts/data/models/saved_post_api_models.dart';
import 'package:mobile_social_network/features/saved_posts/domain/entities/saved_post.dart';
import 'package:mobile_social_network/features/saved_posts/domain/repositories/saved_posts_repository.dart';

class SavedPostsRepositoryImpl implements SavedPostsRepository {
  SavedPostsRepositoryImpl(this._remote);

  final SavedPostsRemoteDataSource _remote;

  @override
  Future<({List<SavedPost> items, int total})> list({
    int limit = 20,
    int offset = 0,
  }) async {
    final dto = await _remote.list(limit: limit, offset: offset);
    return (items: dto.items.map(_map).toList(), total: dto.total);
  }

  @override
  Future<void> save(String postId) => _remote.save(postId);

  @override
  Future<void> remove(String postId) => _remote.remove(postId);

  @override
  Future<void> addTag(String postId, String tagId) =>
      _remote.addTag(postId, tagId);

  @override
  Future<void> removeTag(String postId, String tagId) =>
      _remote.removeTag(postId, tagId);

  SavedPost _map(SavedPostDto dto) => SavedPost(
    post: dto.post.toEntity(),
    savedAt: dto.savedAt,
    tags: dto.tags
        .map(
          (tag) => CustomTag(
            tagId: tag.tagId,
            name: tag.name,
            createdAt: tag.createdAt,
          ),
        )
        .toList(),
  );
}
