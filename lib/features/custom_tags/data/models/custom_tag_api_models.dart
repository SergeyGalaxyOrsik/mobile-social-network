class CustomTagDto {
  const CustomTagDto({required this.tagId, required this.name, this.createdAt});

  final String tagId;
  final String name;
  final String? createdAt;

  factory CustomTagDto.fromJson(Map<String, dynamic> json) {
    return CustomTagDto(
      tagId:
          json['tagId'] as String? ??
          json['tag_id'] as String? ??
          json['id'] as String? ??
          '',
      name: json['name'] as String? ?? '',
      createdAt: json['createdAt'] as String? ?? json['created_at'] as String?,
    );
  }
}

class CustomTagsListResponseDto {
  const CustomTagsListResponseDto({required this.items, required this.total});

  final List<CustomTagDto> items;
  final int total;

  factory CustomTagsListResponseDto.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List<dynamic>? ?? const [];
    final rawTotal = json['total'];
    return CustomTagsListResponseDto(
      items: rawItems
          .map((e) => CustomTagDto.fromJson(e as Map<String, dynamic>))
          .where((e) => e.tagId.isNotEmpty)
          .toList(),
      total: rawTotal is num ? rawTotal.toInt() : rawItems.length,
    );
  }
}
