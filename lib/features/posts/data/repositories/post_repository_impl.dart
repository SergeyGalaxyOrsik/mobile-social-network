import 'package:mobile_social_network/core/network/api_exception.dart';
import 'package:mobile_social_network/features/posts/data/datasources/feed_cache_datasource.dart';
import 'package:mobile_social_network/features/posts/data/datasources/posts_remote_datasource.dart';
import 'package:mobile_social_network/features/posts/data/mappers/post_response_dto_mapper.dart';
import 'package:mobile_social_network/features/posts/data/models/create_post_dto.dart';
import 'package:mobile_social_network/features/posts/domain/entities/post_entity.dart';
import 'package:mobile_social_network/features/posts/domain/entities/post_visibility.dart';
import 'package:mobile_social_network/features/posts/domain/repositories/post_repository.dart';

class PostRepositoryImpl implements PostRepository {
  PostRepositoryImpl({
    required PostsRemoteDataSource remote,
    required PostRepository local,
    required FeedCacheDataSource feedCache,
  }) : _remote = remote,
       _local = local,
       _feedCache = feedCache;

  final PostsRemoteDataSource _remote;
  final PostRepository _local;
  final FeedCacheDataSource _feedCache;

  @override
  Future<List<PostEntity>> getPosts() async {
    try {
      final feed = await _remote.getFeed();
      final list = feed.items.map((dto) => dto.toEntity()).toList();
      try {
        return await _feedCache.replaceFromFeed(list);
      } catch (_) {
        return list;
      }
    } on ApiException {
      return _feedCache.readCachedFeed();
    }
  }

  @override
  Future<int> createPost(PostEntity post) async {
    final dto = CreatePostDto(
      content: post.content,
      visibility: post.visibility == PostVisibility.public
          ? null
          : post.visibility,
      mediaIds: post.mediaIds,
    );
    final res = await _remote.createPost(dto);
    final fromApi = res.toEntity();
    final merged = PostEntity(
      localId: null,
      postId: fromApi.postId,
      userId: fromApi.userId,
      content: fromApi.content,
      createdAt: fromApi.createdAt,
      updatedAt: fromApi.updatedAt,
      visibility: fromApi.visibility,
      postCode: fromApi.postCode,
      image: post.image,
      media: fromApi.media,
      likesCount: fromApi.likesCount,
      commentsCount: fromApi.commentsCount,
    );
    return _local.createPost(merged);
  }

  @override
  Future<void> updatePost(PostEntity post) => _local.updatePost(post);

  @override
  Future<void> deletePost(int localId) => _local.deletePost(localId);
}
