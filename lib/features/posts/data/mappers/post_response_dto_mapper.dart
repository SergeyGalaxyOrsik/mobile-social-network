import 'package:mobile_social_network/features/posts/data/models/post_response_dto.dart';
import 'package:mobile_social_network/features/posts/domain/entities/post_entity.dart';
import 'package:mobile_social_network/features/posts/domain/entities/post_media_item.dart';

extension PostResponseDtoMapper on PostResponseDto {
  PostEntity toEntity() {
    return PostEntity(
      postId: postId,
      userId: userId,
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
