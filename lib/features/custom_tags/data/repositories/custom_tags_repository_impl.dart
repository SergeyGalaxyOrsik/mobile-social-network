import 'package:mobile_social_network/features/custom_tags/data/datasources/custom_tags_remote_datasource.dart';
import 'package:mobile_social_network/features/custom_tags/data/models/custom_tag_api_models.dart';
import 'package:mobile_social_network/features/custom_tags/domain/entities/custom_tag.dart';
import 'package:mobile_social_network/features/custom_tags/domain/repositories/custom_tags_repository.dart';

class CustomTagsRepositoryImpl implements CustomTagsRepository {
  CustomTagsRepositoryImpl(this._remote);

  final CustomTagsRemoteDataSource _remote;

  @override
  Future<({List<CustomTag> items, int total})> list({
    int limit = 20,
    int offset = 0,
  }) async {
    final dto = await _remote.list(limit: limit, offset: offset);
    return (items: dto.items.map(_map).toList(), total: dto.total);
  }

  @override
  Future<CustomTag> create(String name) async {
    return _map(await _remote.create(name.trim()));
  }

  @override
  Future<CustomTag> update(String tagId, String name) async {
    return _map(await _remote.update(tagId, name.trim()));
  }

  @override
  Future<void> delete(String tagId) => _remote.delete(tagId);

  CustomTag _map(CustomTagDto dto) =>
      CustomTag(tagId: dto.tagId, name: dto.name, createdAt: dto.createdAt);
}
