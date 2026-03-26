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

class PostResponseDto {
  const PostResponseDto({
    required this.postId,
    required this.userId,
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
    return PostResponseDto(
      postId: json['post_id'] as String,
      userId: json['user_id'] as String,
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
