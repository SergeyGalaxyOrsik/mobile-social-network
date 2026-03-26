import 'package:mobile_social_network/features/posts/domain/entities/comment_entity.dart';

class CreateCommentDto {
  const CreateCommentDto({required this.content});

  final String content;

  Map<String, dynamic> toJson() => {'content': content};
}

class CreatePostReactionDto {
  const CreatePostReactionDto({this.reactionType = 'like'});

  final String reactionType;

  Map<String, dynamic> toJson() => {'reaction_type': reactionType};
}

class CommentResponseDto {
  const CommentResponseDto({
    required this.commentId,
    required this.postId,
    required this.userId,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    required this.likesCount,
  });

  final String commentId;
  final String postId;
  final String userId;
  final String content;
  final String createdAt;
  final String updatedAt;
  final int likesCount;

  factory CommentResponseDto.fromJson(Map<String, dynamic> json) {
    final likesRaw = json['likes_count'];
    return CommentResponseDto(
      commentId: json['comment_id'] as String,
      postId: json['post_id'] as String,
      userId: json['user_id'] as String,
      content: json['content'] as String,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
      likesCount: likesRaw is num ? likesRaw.toInt() : 0,
    );
  }

  CommentEntity toEntity() => CommentEntity(
    commentId: commentId,
    postId: postId,
    userId: userId,
    content: content,
    createdAt: createdAt,
    updatedAt: updatedAt,
    likesCount: likesCount,
  );
}

class CommentsListResponseDto {
  const CommentsListResponseDto({required this.items, required this.total});

  final List<CommentResponseDto> items;
  final int total;

  factory CommentsListResponseDto.fromJson(Map<String, dynamic> json) {
    final raw = json['items'] as List<dynamic>? ?? [];
    final totalRaw = json['total'];
    return CommentsListResponseDto(
      items: raw
          .map((e) => CommentResponseDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: totalRaw is num ? totalRaw.toInt() : 0,
    );
  }
}
