import 'package:mobile_social_network/features/custom_tags/domain/entities/custom_tag.dart';

abstract class CustomTagsRepository {
  Future<({List<CustomTag> items, int total})> list({
    int limit = 20,
    int offset = 0,
  });

  Future<CustomTag> create(String name);

  Future<CustomTag> update(String tagId, String name);

  Future<void> delete(String tagId);
}
