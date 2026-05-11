import 'package:mobile_social_network/features/posts/data/models/post_response_dto.dart';

class UserSearchItemDto {
  const UserSearchItemDto({
    required this.userId,
    required this.username,
    this.bio,
  });

  final String userId;
  final String username;
  final String? bio;

  factory UserSearchItemDto.fromJson(Map<String, dynamic> json) {
    return UserSearchItemDto(
      userId: json['user_id'] as String,
      username: json['username'] as String,
      bio: json['bio'] as String?,
    );
  }
}

class UserSearchResponseDto {
  const UserSearchResponseDto({required this.items});

  final List<UserSearchItemDto> items;

  factory UserSearchResponseDto.fromJson(Map<String, dynamic> json) {
    final raw = json['items'] as List<dynamic>? ?? const [];
    return UserSearchResponseDto(
      items: raw
          .map((e) => UserSearchItemDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class FriendListItemDto {
  const FriendListItemDto({
    required this.userId,
    required this.username,
    this.bio,
    required this.avatar,
    required this.friendshipCreatedAt,
  });

  final String userId;
  final String username;
  final String? bio;
  final ProfileAvatarDto avatar;
  final String friendshipCreatedAt;

  factory FriendListItemDto.fromJson(Map<String, dynamic> json) {
    return FriendListItemDto(
      userId: json['user_id'] as String,
      username: json['username'] as String,
      bio: json['bio'] as String?,
      avatar: ProfileAvatarDto.fromJson(
        json['avatar'] as Map<String, dynamic>?,
      ),
      friendshipCreatedAt: json['friendship_created_at'] as String,
    );
  }
}

class FriendsListResponseDto {
  const FriendsListResponseDto({required this.items, required this.total});

  final List<FriendListItemDto> items;
  final int total;

  factory FriendsListResponseDto.fromJson(Map<String, dynamic> json) {
    final raw = json['items'] as List<dynamic>? ?? const [];
    final totalRaw = json['total'];
    return FriendsListResponseDto(
      items: raw
          .map((e) => FriendListItemDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: totalRaw is num ? totalRaw.toInt() : 0,
    );
  }
}

enum FriendRequestOutcomeDto { pending, friends }

class SendFriendRequestResponseDto {
  const SendFriendRequestResponseDto({required this.outcome, this.requestId});

  final FriendRequestOutcomeDto outcome;
  final String? requestId;

  factory SendFriendRequestResponseDto.fromJson(Map<String, dynamic> json) {
    final raw = json['outcome'] as String?;
    final outcome = raw == 'friends'
        ? FriendRequestOutcomeDto.friends
        : FriendRequestOutcomeDto.pending;
    return SendFriendRequestResponseDto(
      outcome: outcome,
      requestId: json['request_id'] as String?,
    );
  }
}

class FriendRequestItemDto {
  const FriendRequestItemDto({
    required this.requestId,
    required this.peerUserId,
    required this.peerUsername,
    required this.createdAt,
  });

  final String requestId;
  final String peerUserId;
  final String peerUsername;
  final String createdAt;

  factory FriendRequestItemDto.fromJson(Map<String, dynamic> json) {
    return FriendRequestItemDto(
      requestId: json['request_id'] as String,
      peerUserId: json['peer_user_id'] as String,
      peerUsername: json['peer_username'] as String,
      createdAt: json['created_at'] as String,
    );
  }
}

class FriendRequestsListResponseDto {
  const FriendRequestsListResponseDto({
    required this.items,
    required this.total,
  });

  final List<FriendRequestItemDto> items;
  final int total;

  factory FriendRequestsListResponseDto.fromJson(Map<String, dynamic> json) {
    final raw = json['items'] as List<dynamic>? ?? const [];
    final totalRaw = json['total'];
    return FriendRequestsListResponseDto(
      items: raw
          .map((e) => FriendRequestItemDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: totalRaw is num ? totalRaw.toInt() : 0,
    );
  }
}

class ProfileAvatarDto {
  const ProfileAvatarDto({this.mediaId, this.url});

  final String? mediaId;
  final String? url;

  factory ProfileAvatarDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const ProfileAvatarDto();
    }
    return ProfileAvatarDto(
      mediaId: json['media_id'] as String?,
      url: json['url'] as String?,
    );
  }
}

class ProfileResponseDto {
  const ProfileResponseDto({
    required this.userId,
    required this.username,
    this.bio,
    this.birthDate,
    required this.avatar,
    required this.relationship,
    required this.posts,
    required this.postsTotal,
  });

  final String userId;
  final String username;
  final String? bio;
  final String? birthDate;
  final ProfileAvatarDto avatar;
  final String relationship;
  final List<PostResponseDto> posts;
  final int postsTotal;

  factory ProfileResponseDto.fromJson(Map<String, dynamic> json) {
    final rawPosts = json['posts'] as List<dynamic>? ?? const [];
    final totalRaw = json['posts_total'];
    return ProfileResponseDto(
      userId: json['user_id'] as String,
      username: json['username'] as String,
      bio: json['bio'] as String?,
      birthDate: json['birth_date'] as String?,
      avatar: ProfileAvatarDto.fromJson(
        json['avatar'] as Map<String, dynamic>?,
      ),
      relationship: json['relationship'] as String? ?? 'none',
      posts: rawPosts
          .map((e) => PostResponseDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      postsTotal: totalRaw is num ? totalRaw.toInt() : 0,
    );
  }
}

class ReportUserRequestDto {
  const ReportUserRequestDto({required this.reasonCode, this.details});

  final String reasonCode;
  final String? details;

  Map<String, dynamic> toJson() => {
    'reason_code': reasonCode,
    if (details != null && details!.isNotEmpty) 'details': details,
  };
}

class ReportUserResponseDto {
  const ReportUserResponseDto({required this.reportId});

  final String reportId;

  factory ReportUserResponseDto.fromJson(Map<String, dynamic> json) {
    return ReportUserResponseDto(reportId: json['report_id'] as String);
  }
}
