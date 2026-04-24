import 'package:mobile_social_network/features/posts/domain/entities/post_visibility.dart';

class PostMediaItemDto {
  const PostMediaItemDto({
    required this.mediaId,
    required this.type,
    required this.url,
  });

  final String mediaId;
  final String type;
  final String url;

  factory PostMediaItemDto.fromJson(Map<String, dynamic> json) {
    return PostMediaItemDto(
      mediaId: json['media_id'] as String,
      type: json['type'] as String,
      url: json['url'] as String,
    );
  }
}

class PostAuthorAvatarDto {
  const PostAuthorAvatarDto({this.mediaId, this.url});

  final String? mediaId;
  final String? url;

  factory PostAuthorAvatarDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const PostAuthorAvatarDto();
    }
    return PostAuthorAvatarDto(
      mediaId: json['media_id'] as String?,
      url: json['url'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'media_id': mediaId,
    'url': url,
  };
}

class PostAuthorDto {
  const PostAuthorDto({
    required this.username,
    this.bio,
    required this.avatar,
  });

  final String username;
  final String? bio;
  final PostAuthorAvatarDto avatar;

  factory PostAuthorDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const PostAuthorDto(
        username: '',
        bio: null,
        avatar: PostAuthorAvatarDto(),
      );
    }
    return PostAuthorDto(
      username: json['username'] as String? ?? '',
      bio: json['bio'] as String?,
      avatar: PostAuthorAvatarDto.fromJson(
        json['avatar'] as Map<String, dynamic>?,
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    'username': username,
    'bio': bio,
    'avatar': avatar.toJson(),
  };
}

class PostResponseDto {
  const PostResponseDto({
    required this.postId,
    required this.userId,
    this.author,
    required this.content,
    required this.visibility,
    required this.postCode,
    required this.createdAt,
    required this.updatedAt,
    this.media = const [],
    this.likesCount = 0,
    this.commentsCount = 0,
  });

  final String postId;
  final String userId;
  final PostAuthorDto? author;
  final String content;
  final PostVisibility visibility;
  final String postCode;
  final String createdAt;
  final String updatedAt;
  final List<PostMediaItemDto> media;
  final int likesCount;
  final int commentsCount;

  factory PostResponseDto.fromJson(Map<String, dynamic> json) {
    final rawMedia = json['media'] as List<dynamic>?;
    final likesRaw = json['likes_count'];
    final commentsRaw = json['comments_count'];
    final rawAuthor = json['author'];
    PostAuthorDto? authorDto;
    if (rawAuthor is Map<String, dynamic>) {
      final parsed = PostAuthorDto.fromJson(rawAuthor);
      if (parsed.username.isNotEmpty) {
        authorDto = parsed;
      }
    }
    return PostResponseDto(
      postId: json['post_id'] as String,
      userId: json['user_id'] as String,
      author: authorDto,
      content: json['content'] as String,
      visibility: PostVisibility.fromJson(json['visibility'] as String?),
      postCode: json['post_code'] as String,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
      likesCount: likesRaw is num ? likesRaw.toInt() : 0,
      commentsCount: commentsRaw is num ? commentsRaw.toInt() : 0,
      media: rawMedia == null
          ? const []
          : rawMedia
                .map(
                  (e) => PostMediaItemDto.fromJson(e as Map<String, dynamic>),
                )
                .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'post_id': postId,
    'user_id': userId,
    if (author != null) 'author': author!.toJson(),
    'content': content,
    'visibility': visibility.toJson(),
    'post_code': postCode,
    'created_at': createdAt,
    'updated_at': updatedAt,
    'likes_count': likesCount,
    'comments_count': commentsCount,
    'media': media
        .map(
          (m) => <String, dynamic>{
            'media_id': m.mediaId,
            'type': m.type,
            'url': m.url,
          },
        )
        .toList(),
  };
}
