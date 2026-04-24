import 'package:mobile_social_network/features/posts/domain/entities/post_author.dart';
import 'package:mobile_social_network/features/posts/domain/entities/post_media_item.dart';
import 'package:mobile_social_network/features/posts/domain/entities/post_visibility.dart';

class PostEntity {
  const PostEntity({
    this.localId,
    this.postId,
    this.userId,
    required this.content,
    required this.createdAt,
    this.updatedAt,
    this.visibility = PostVisibility.public,
    this.postCode,
    this.image,
    this.media,
    this.mediaIds,
    this.author,
    this.likesCount = 0,
    this.commentsCount = 0,
  });

  final int? localId;
  final String? postId;
  final String? userId;
  final String content;
  final String createdAt;
  final String? updatedAt;
  final PostVisibility visibility;
  final String? postCode;
  final String? image;
  final List<PostMediaItem>? media;
  final List<String>? mediaIds;
  final PostAuthor? author;
  final int likesCount;
  final int commentsCount;

  PostEntity copyWith({
    int? localId,
    String? postId,
    String? userId,
    String? content,
    String? createdAt,
    String? updatedAt,
    PostVisibility? visibility,
    String? postCode,
    String? image,
    List<PostMediaItem>? media,
    List<String>? mediaIds,
    PostAuthor? author,
    int? likesCount,
    int? commentsCount,
  }) {
    return PostEntity(
      localId: localId ?? this.localId,
      postId: postId ?? this.postId,
      userId: userId ?? this.userId,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      visibility: visibility ?? this.visibility,
      postCode: postCode ?? this.postCode,
      image: image ?? this.image,
      media: media ?? this.media,
      mediaIds: mediaIds ?? this.mediaIds,
      author: author ?? this.author,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'note': content,
      'date': createdAt,
      'visibility': visibility.toJson(),
    };
    if (localId != null) {
      map['id'] = localId;
    }
    if (userId != null) {
      map['userId'] = userId;
    }
    if (image != null) {
      map['image'] = image;
    }
    if (postId != null) {
      map['post_id'] = postId;
    }
    if (postCode != null) {
      map['post_code'] = postCode;
    }
    if (updatedAt != null) {
      map['updated_at'] = updatedAt;
    }
    return map;
  }

  factory PostEntity.fromMap(Map<String, dynamic> map) {
    return PostEntity(
      localId: map['id'] as int?,
      postId: map['post_id'] as String?,
      userId: map['userId'] as String?,
      content: map['note'] as String,
      createdAt: map['date'] as String,
      updatedAt: map['updated_at'] as String?,
      visibility: PostVisibility.fromJson(map['visibility'] as String?),
      postCode: map['post_code'] as String?,
      image: map['image'] as String?,
      media: null,
      mediaIds: null,
    );
  }
}
