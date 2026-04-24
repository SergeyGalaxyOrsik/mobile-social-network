import 'package:mobile_social_network/features/posts/domain/entities/post_entity.dart';
import 'package:mobile_social_network/features/social_users/domain/entities/profile_relationship.dart';

class ProfileWithPosts {
  const ProfileWithPosts({
    required this.userId,
    required this.username,
    this.bio,
    this.birthDate,
    this.avatarMediaId,
    this.avatarUrl,
    required this.relationship,
    required this.posts,
    required this.postsTotal,
  });

  final String userId;
  final String username;
  final String? bio;
  final String? birthDate;
  final String? avatarMediaId;
  final String? avatarUrl;
  final ProfileRelationship relationship;
  final List<PostEntity> posts;
  final int postsTotal;

  ProfileWithPosts copyWith({
    String? userId,
    String? username,
    String? bio,
    String? birthDate,
    String? avatarMediaId,
    String? avatarUrl,
    ProfileRelationship? relationship,
    List<PostEntity>? posts,
    int? postsTotal,
  }) {
    return ProfileWithPosts(
      userId: userId ?? this.userId,
      username: username ?? this.username,
      bio: bio ?? this.bio,
      birthDate: birthDate ?? this.birthDate,
      avatarMediaId: avatarMediaId ?? this.avatarMediaId,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      relationship: relationship ?? this.relationship,
      posts: posts ?? this.posts,
      postsTotal: postsTotal ?? this.postsTotal,
    );
  }
}
