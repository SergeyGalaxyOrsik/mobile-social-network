import 'package:mobile_social_network/features/posts/domain/entities/post_entity.dart';
import 'package:mobile_social_network/features/posts/domain/entities/post_search_sort.dart';
import 'package:mobile_social_network/features/posts/domain/entities/post_visibility.dart';

abstract class PostRepository {
  Future<List<PostEntity>> getPosts();
  Future<int> createPost(PostEntity post);
  Future<void> updatePost(PostEntity post);
  Future<void> deletePost(int localId);

  /// Поиск постов на сервере (`GET /posts/search`); кеш ленты не использует.
  Future<({List<PostEntity> items, int total})> searchPosts({
    String? q,
    PostSearchSort? sort,
    String? authorUserId,
    PostVisibility? visibility,
    int? limit,
    int? offset,
  });

  Future<({List<PostEntity> items, int total})> getPostsByHashtag(
    String hashtag, {
    int? limit,
    int? offset,
  });
}
