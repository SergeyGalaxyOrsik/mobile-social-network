import 'package:mobile_social_network/features/posts/domain/entities/comment_entity.dart';
import 'package:mobile_social_network/features/posts/domain/entities/post_entity.dart';

/// Результат GET /posts/{postId}/comments.
class CommentsListResult {
  const CommentsListResult({
    required this.items,
    required this.total,
  });

  final List<CommentEntity> items;
  final int total;
}

/// Реакции и комментарии к постам (только сеть).
abstract class PostEngagementRepository {
  Future<void> addPostReaction(String postId);

  Future<void> removePostReaction(String postId);

  /// Актуальные счётчики и медиа с сервера.
  Future<PostEntity> getPost(String postId);

  Future<CommentsListResult> listComments(
    String postId, {
    int limit = 20,
    int offset = 0,
  });

  Future<CommentEntity> createComment(String postId, String content);

  Future<void> deleteComment(String postId, String commentId);

  Future<void> likeComment(String postId, String commentId);

  Future<void> unlikeComment(String postId, String commentId);
}
