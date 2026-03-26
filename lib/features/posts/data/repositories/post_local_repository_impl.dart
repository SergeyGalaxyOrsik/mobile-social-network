import 'package:mobile_social_network/core/database/database_helper.dart';
import 'package:mobile_social_network/features/posts/domain/entities/post_entity.dart';
import 'package:mobile_social_network/features/posts/domain/repositories/post_repository.dart';

class PostLocalRepositoryImpl implements PostRepository {
  @override
  Future<List<PostEntity>> getPosts() async {
    final db = await DatabaseHelper.instance.database;
    final List<Map<String, dynamic>> maps = await db.query('notes');
    return List.generate(maps.length, (i) => PostEntity.fromMap(maps[i]));
  }

  @override
  Future<int> createPost(PostEntity post) async {
    final db = await DatabaseHelper.instance.database;
    final map = post.toMap();
    map.remove('id');
    return db.insert('notes', map);
  }

  @override
  Future<void> updatePost(PostEntity post) async {
    final db = await DatabaseHelper.instance.database;
    final id = post.localId;
    if (id == null) return;
    await db.update('notes', post.toMap(), where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<void> deletePost(int localId) async {
    final db = await DatabaseHelper.instance.database;
    await db.delete('notes', where: 'id = ?', whereArgs: [localId]);
  }
}
