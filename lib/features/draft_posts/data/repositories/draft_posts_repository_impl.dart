import 'package:mobile_social_network/features/draft_posts/data/datasources/draft_posts_remote_datasource.dart';
import 'package:mobile_social_network/features/draft_posts/data/models/draft_post_api_models.dart';
import 'package:mobile_social_network/features/draft_posts/domain/entities/draft_post.dart';
import 'package:mobile_social_network/features/draft_posts/domain/repositories/draft_posts_repository.dart';
import 'package:mobile_social_network/features/posts/data/mappers/post_response_dto_mapper.dart';
import 'package:mobile_social_network/features/posts/domain/entities/post_entity.dart';
import 'package:mobile_social_network/features/posts/domain/entities/post_visibility.dart';

class DraftPostsRepositoryImpl implements DraftPostsRepository {
  DraftPostsRepositoryImpl(this._remote);

  final DraftPostsRemoteDataSource _remote;

  @override
  Future<({List<DraftPost> items, int total})> list({
    int limit = 20,
    int offset = 0,
  }) async {
    final dto = await _remote.list(limit: limit, offset: offset);
    return (items: dto.items.map(_map).toList(), total: dto.total);
  }

  @override
  Future<DraftPost> create({
    String? content,
    PostVisibility? visibility,
    List<String>? mediaIds,
  }) async {
    return _map(
      await _remote.create(
        UpsertDraftPostDto(
          content: content,
          visibility: visibility,
          mediaIds: mediaIds,
        ),
      ),
    );
  }

  @override
  Future<DraftPost> get(String draftId) async =>
      _map(await _remote.get(draftId));

  @override
  Future<DraftPost> update(
    String draftId, {
    String? content,
    PostVisibility? visibility,
    List<String>? mediaIds,
  }) async {
    return _map(
      await _remote.update(
        draftId,
        UpsertDraftPostDto(
          content: content,
          visibility: visibility,
          mediaIds: mediaIds,
        ),
      ),
    );
  }

  @override
  Future<void> delete(String draftId) => _remote.delete(draftId);

  @override
  Future<PostEntity> publish(String draftId) async {
    return (await _remote.publish(draftId)).toEntity();
  }

  @override
  Future<DraftPost> getByCode(String postCode) async {
    return _map(await _remote.getByCode(postCode));
  }

  DraftPost _map(DraftPostDto dto) => DraftPost(
    draftId: dto.draftId,
    postCode: dto.postCode,
    content: dto.content,
    visibility: dto.visibility,
    mediaIds: dto.mediaIds,
    createdAt: dto.createdAt,
    updatedAt: dto.updatedAt,
  );
}
