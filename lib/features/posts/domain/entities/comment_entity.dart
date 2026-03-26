class CommentEntity {
  const CommentEntity({
    required this.commentId,
    required this.postId,
    required this.userId,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    this.likesCount = 0,
  });

  final String commentId;
  final String postId;
  final String userId;
  final String content;
  final String createdAt;
  final String updatedAt;
  final int likesCount;

  CommentEntity copyWith({
    String? commentId,
    String? postId,
    String? userId,
    String? content,
    String? createdAt,
    String? updatedAt,
    int? likesCount,
  }) {
    return CommentEntity(
      commentId: commentId ?? this.commentId,
      postId: postId ?? this.postId,
      userId: userId ?? this.userId,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      likesCount: likesCount ?? this.likesCount,
    );
  }
}
