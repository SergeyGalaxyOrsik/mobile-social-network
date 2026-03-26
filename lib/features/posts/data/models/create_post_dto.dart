import 'package:mobile_social_network/features/posts/domain/entities/post_visibility.dart';

class CreatePostDto {
  const CreatePostDto({required this.content, this.visibility, this.mediaIds});

  final String content;
  final PostVisibility? visibility;
  final List<String>? mediaIds;

  Map<String, dynamic> toJson() => {
    'content': content,
    if (visibility != null) 'visibility': visibility!.toJson(),
    if (mediaIds != null && mediaIds!.isNotEmpty) 'mediaIds': mediaIds,
  };
}
