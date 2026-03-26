import 'package:mobile_social_network/features/posts/domain/entities/post_entity.dart';

abstract class PostRepository {
  Future<List<PostEntity>> getPosts();
  Future<int> createPost(PostEntity post);
  Future<void> updatePost(PostEntity post);
  Future<void> deletePost(int localId);
}
