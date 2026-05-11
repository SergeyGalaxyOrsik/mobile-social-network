import 'package:mobile_social_network/features/custom_tags/data/models/custom_tag_api_models.dart';
import 'package:mobile_social_network/features/posts/data/models/post_response_dto.dart';

class SavedPostDto {
  const SavedPostDto({required this.post, this.savedAt, this.tags = const []});

  final PostResponseDto post;
  final String? savedAt;
  final List<CustomTagDto> tags;

  factory SavedPostDto.fromJson(Map<String, dynamic> json) {
    final rawTags = json['tags'] as List<dynamic>?;
    return SavedPostDto(
      post: PostResponseDto.fromJson(
        (json['post'] as Map<String, dynamic>?) ?? json,
      ),
      savedAt: json['savedAt'] as String? ?? json['saved_at'] as String?,
      tags: rawTags == null
          ? const []
          : rawTags
                .map((e) => CustomTagDto.fromJson(e as Map<String, dynamic>))
                .where((e) => e.tagId.isNotEmpty)
                .toList(),
    );
  }
}

class SavedPostsListResponseDto {
  const SavedPostsListResponseDto({required this.items, required this.total});

  final List<SavedPostDto> items;
  final int total;

  factory SavedPostsListResponseDto.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List<dynamic>? ?? const [];
    final rawTotal = json['total'];
    return SavedPostsListResponseDto(
      items: rawItems
          .map((e) => SavedPostDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: rawTotal is num ? rawTotal.toInt() : rawItems.length,
    );
  }
}
