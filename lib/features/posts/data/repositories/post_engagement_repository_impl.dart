import 'package:mobile_social_network/features/posts/data/datasources/posts_engagement_remote_datasource.dart';
import 'package:mobile_social_network/features/posts/data/mappers/post_response_dto_mapper.dart';
import 'package:mobile_social_network/features/posts/data/models/comment_api_models.dart';
import 'package:mobile_social_network/features/posts/domain/entities/comment_entity.dart';
import 'package:mobile_social_network/features/posts/domain/entities/post_entity.dart';
import 'package:mobile_social_network/features/posts/domain/repositories/post_engagement_repository.dart';

class PostEngagementRepositoryImpl implements PostEngagementRepository {
  PostEngagementRepositoryImpl(this._remote);

  final PostsEngagementRemoteDataSource _remote;

  @override
  Future<void> addPostReaction(String postId) {
    return _remote.addPostReaction(
      postId,
      const CreatePostReactionDto(),
    );
  }

  @override
  Future<void> removePostReaction(String postId) {
    return _remote.removePostReaction(postId);
  }

  @override
  Future<PostEntity> getPost(String postId) async {
    final dto = await _remote.getPost(postId);
    return dto.toEntity();
  }

  @override
  Future<CommentsListResult> listComments(
    String postId, {
    int limit = 20,
    int offset = 0,
  }) async {
    final dto = await _remote.listComments(
      postId,
      limit: limit,
      offset: offset,
    );
    return CommentsListResult(
      items: dto.items.map((e) => e.toEntity()).toList(),
      total: dto.total,
    );
  }

  @override
  Future<CommentEntity> createComment(String postId, String content) async {
    final dto = await _remote.createComment(
      postId,
      CreateCommentDto(content: content),
    );
    return dto.toEntity();
  }

  @override
  Future<void> deleteComment(String postId, String commentId) {
    return _remote.deleteComment(postId, commentId);
  }

  @override
  Future<void> likeComment(String postId, String commentId) {
    return _remote.likeComment(postId, commentId);
  }

  @override
  Future<void> unlikeComment(String postId, String commentId) {
    return _remote.unlikeComment(postId, commentId);
  }
}
