import 'package:mobile_social_network/features/posts/domain/entities/post_visibility.dart';

class DraftPost {
  const DraftPost({
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
}
