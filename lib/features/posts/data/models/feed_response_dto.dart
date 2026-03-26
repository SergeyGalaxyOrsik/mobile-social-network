import 'package:mobile_social_network/features/posts/data/models/post_response_dto.dart';

class FeedResponseDto {
  const FeedResponseDto({required this.items, required this.total});

  final List<PostResponseDto> items;
  final num total;

  factory FeedResponseDto.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List<dynamic>? ?? [];
    return FeedResponseDto(
      items: rawItems
          .map((e) => PostResponseDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: json['total'] as num? ?? 0,
    );
  }
}
