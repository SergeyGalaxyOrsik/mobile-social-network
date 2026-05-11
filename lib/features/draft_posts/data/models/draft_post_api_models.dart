import 'package:mobile_social_network/features/posts/data/models/post_response_dto.dart';
import 'package:mobile_social_network/features/posts/domain/entities/post_visibility.dart';

class DraftPostDto {
  const DraftPostDto({
    required this.draftId,
    this.postCode,
    this.content,
    required this.visibility,
    this.mediaIds = const [],
    this.createdAt,
    this.updatedAt,
  });

  final String draftId;
  final String? postCode;
  final String? content;
  final PostVisibility visibility;
  final List<String> mediaIds;
  final String? createdAt;
  final String? updatedAt;

  factory DraftPostDto.fromJson(Map<String, dynamic> json) {
    final rawMedia = json['mediaIds'] ?? json['media_ids'];
    return DraftPostDto(
      draftId:
          json['draftId'] as String? ??
          json['draft_id'] as String? ??
          json['id'] as String? ??
          '',
      postCode: json['postCode'] as String? ?? json['post_code'] as String?,
      content: json['content'] as String?,
      visibility: PostVisibility.fromJson(json['visibility'] as String?),
      mediaIds: rawMedia is List<dynamic>
          ? rawMedia.whereType<String>().toList()
          : const [],
      createdAt: json['createdAt'] as String? ?? json['created_at'] as String?,
      updatedAt: json['updatedAt'] as String? ?? json['updated_at'] as String?,
    );
  }
}

class DraftPostsListResponseDto {
  const DraftPostsListResponseDto({required this.items, required this.total});

  final List<DraftPostDto> items;
  final int total;

  factory DraftPostsListResponseDto.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List<dynamic>? ?? const [];
    final rawTotal = json['total'];
    return DraftPostsListResponseDto(
      items: rawItems
          .map((e) => DraftPostDto.fromJson(e as Map<String, dynamic>))
          .where((e) => e.draftId.isNotEmpty)
          .toList(),
      total: rawTotal is num ? rawTotal.toInt() : rawItems.length,
    );
  }
}

class UpsertDraftPostDto {
  const UpsertDraftPostDto({this.content, this.visibility, this.mediaIds});

  final String? content;
  final PostVisibility? visibility;
  final List<String>? mediaIds;

  Map<String, dynamic> toJson() => <String, dynamic>{
    if (content != null) 'content': content,
    if (visibility != null) 'visibility': visibility!.toJson(),
    if (mediaIds != null) 'mediaIds': mediaIds,
  };
}

class PublishedDraftPostDto {
  const PublishedDraftPostDto(this.post);

  final PostResponseDto post;
}
