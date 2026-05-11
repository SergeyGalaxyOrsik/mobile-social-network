import 'package:mobile_social_network/features/draft_posts/domain/entities/draft_post.dart';
import 'package:mobile_social_network/features/posts/domain/entities/post_entity.dart';
import 'package:mobile_social_network/features/posts/domain/entities/post_visibility.dart';

abstract class DraftPostsRepository {
  Future<({List<DraftPost> items, int total})> list({
    int limit = 20,
    int offset = 0,
  });

  Future<DraftPost> create({
    String? content,
    PostVisibility? visibility,
    List<String>? mediaIds,
  });

  Future<DraftPost> get(String draftId);

  Future<DraftPost> update(
    String draftId, {
    String? content,
    PostVisibility? visibility,
    List<String>? mediaIds,
  });

  Future<void> delete(String draftId);

  Future<PostEntity> publish(String draftId);

  Future<DraftPost> getByCode(String postCode);
}
