/// Соответствует `sort` в `GET /users/me/friends`.
enum FriendsListSort {
  relevance,
  usernameAsc,
  usernameDesc,
  friendshipCreatedAsc,
  friendshipCreatedDesc;

  String toApi() => switch (this) {
    FriendsListSort.relevance => 'relevance',
    FriendsListSort.usernameAsc => 'username_asc',
    FriendsListSort.usernameDesc => 'username_desc',
    FriendsListSort.friendshipCreatedAsc => 'friendship_created_asc',
    FriendsListSort.friendshipCreatedDesc => 'friendship_created_desc',
  };
}
