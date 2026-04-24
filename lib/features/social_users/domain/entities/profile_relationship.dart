enum ProfileRelationship {
  self,
  friend,
  outgoingFriendRequest,
  incomingFriendRequest,
  following,
  none,
  unknown,
}

ProfileRelationship profileRelationshipFromApi(String raw) {
  return switch (raw) {
    'self' => ProfileRelationship.self,
    'friend' => ProfileRelationship.friend,
    'outgoing_friend_request' => ProfileRelationship.outgoingFriendRequest,
    'incoming_friend_request' => ProfileRelationship.incomingFriendRequest,
    'following' => ProfileRelationship.following,
    'none' => ProfileRelationship.none,
    _ => ProfileRelationship.unknown,
  };
}
