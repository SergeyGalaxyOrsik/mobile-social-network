import 'package:mobile_social_network/features/saved_posts/domain/entities/saved_post.dart';

abstract class SavedPostsRepository {
  Future<({List<SavedPost> items, int total})> list({
    int limit = 20,
    int offset = 0,
  });

  Future<void> save(String postId);

  Future<void> remove(String postId);

  Future<void> addTag(String postId, String tagId);

  Future<void> removeTag(String postId, String tagId);
}
