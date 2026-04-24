import 'package:mobile_social_network/features/posts/data/models/post_response_dto.dart';
import 'package:mobile_social_network/features/posts/domain/entities/post_author.dart';
import 'package:mobile_social_network/features/posts/domain/entities/post_entity.dart';
import 'package:mobile_social_network/features/posts/domain/entities/post_media_item.dart';

extension PostResponseDtoMapper on PostResponseDto {
  PostEntity toEntity() {
    final a = author;
    PostAuthor? authorEntity;
    if (a != null && a.username.isNotEmpty) {
      authorEntity = PostAuthor(
        username: a.username,
        bio: a.bio,
        avatarUrl: a.avatar.url,
        avatarMediaId: a.avatar.mediaId,
      );
    }
    return PostEntity(
      postId: postId,
      userId: userId,
      author: authorEntity,
      content: content,
      createdAt: createdAt,
      updatedAt: updatedAt,
      visibility: visibility,
      postCode: postCode,
      likesCount: likesCount,
      commentsCount: commentsCount,
      media: media.isEmpty
          ? null
          : media
                .map(
                  (m) => PostMediaItem(
                    mediaId: m.mediaId,
                    type: m.type,
                    url: m.url,
                  ),
                )
                .toList(),
    );
  }
}
