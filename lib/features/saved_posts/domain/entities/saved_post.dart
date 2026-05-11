import 'package:mobile_social_network/features/custom_tags/domain/entities/custom_tag.dart';
import 'package:mobile_social_network/features/posts/domain/entities/post_entity.dart';

class SavedPost {
  const SavedPost({required this.post, this.savedAt, this.tags = const []});

  final PostEntity post;
  final String? savedAt;
  final List<CustomTag> tags;
}
