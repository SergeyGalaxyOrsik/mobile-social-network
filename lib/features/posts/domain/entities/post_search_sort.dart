/// Соответствует `sort` в `GET /posts/search`.
enum PostSearchSort {
  relevance,
  createdAtDesc,
  createdAtAsc,
  likesDesc,
  commentsDesc;

  String toApi() => switch (this) {
    PostSearchSort.relevance => 'relevance',
    PostSearchSort.createdAtDesc => 'created_at_desc',
    PostSearchSort.createdAtAsc => 'created_at_asc',
    PostSearchSort.likesDesc => 'likes_desc',
    PostSearchSort.commentsDesc => 'comments_desc',
  };
}
