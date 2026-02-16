import 'package:mobile_social_network/core/database/database_helper.dart';
import 'package:mobile_social_network/core/utils/hash_password.dart';
import 'package:mobile_social_network/features/auth/domain/entities/user_entity.dart';
import 'package:mobile_social_network/features/auth/domain/repositories/user_repository.dart';

/// Реализация репозитория пользователей (слой data).
class UserRepositoryImpl implements UserRepository {
  @override
  Future<List<UserEntity>> getUsers() async {
    final db = await DatabaseHelper.instance.database;
    final List<Map<String, dynamic>> maps = await db.query('users');
    return List.generate(maps.length, (i) => UserEntity.fromMap(maps[i]));
  }

  @override
  Future<UserEntity?> getUserByEmail(String email) async {
    final db = await DatabaseHelper.instance.database;
    final maps = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    if (maps.isEmpty) return null;
    return UserEntity.fromMap(maps.first);
  }

  @override
  Future<UserEntity?> getUserById(String id) async {
    final db = await DatabaseHelper.instance.database;
    final maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return UserEntity.fromMap(maps.first);
  }

  @override
  Future<bool> existsUserByEmail(String email) async {
    final user = await getUserByEmail(email);
    return user != null;
  }

  @override
  Future<void> createUser(UserEntity user) async {
    final db = await DatabaseHelper.instance.database;
    final userMap = user.toMap();
    if (user.id.isEmpty) {
      userMap.remove('id');
    }
    if (user.password != null) {
      userMap['password'] = hashPassword(user.password!);
    }
    await db.insert('users', userMap);
  }

  @override
  Future<void> updateUser(UserEntity user) async {
    final db = await DatabaseHelper.instance.database;
    await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  @override
  Future<void> deleteUser(int id) async {
    final db = await DatabaseHelper.instance.database;
    await db.delete('users', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<bool> checkPassword(String email, String inputPassword) async {
    final db = await DatabaseHelper.instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    if (maps.isEmpty) return false;
    final storedHash = maps.first['password'];
    return hashPassword(inputPassword) == storedHash;
  }
}
