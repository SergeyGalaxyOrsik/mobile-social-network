import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import 'package:mobile_social_network/core/database/database_helper.dart';
import 'package:mobile_social_network/features/posts/domain/entities/post_author.dart';
import 'package:mobile_social_network/features/posts/domain/entities/post_entity.dart';
import 'package:mobile_social_network/features/posts/domain/entities/post_media_item.dart';
import 'package:mobile_social_network/features/posts/domain/entities/post_visibility.dart';

const _feedMediaSubdir = 'feed_media';

class FeedCacheDataSource {
  FeedCacheDataSource({Dio? downloadClient}) : _dio = downloadClient ?? Dio();

  final Dio _dio;

  static const _downloadTimeout = Duration(seconds: 45);

  Future<List<PostEntity>> replaceFromFeed(List<PostEntity> posts) async {
    final dir = await getApplicationDocumentsDirectory();
    final mediaDir = Directory(p.join(dir.path, _feedMediaSubdir));
    if (!await mediaDir.exists()) {
      await mediaDir.create(recursive: true);
    }

    final enriched = <PostEntity>[];
    final keptPaths = <String>{};

    for (final post in posts) {
      final media = post.media;
      if (media == null || media.isEmpty) {
        enriched.add(post);
        continue;
      }

      final newMedia = <PostMediaItem>[];
      for (final m in media) {
        if (m.type.startsWith('image/')) {
          final rel = await _ensureImageCached(m.url, mediaDir, dir.path);
          if (rel != null) {
            keptPaths.add(rel);
            newMedia.add(
              PostMediaItem(
                mediaId: m.mediaId,
                type: m.type,
                url: m.url,
                localRelativePath: rel,
              ),
            );
          } else {
            newMedia.add(m);
          }
        } else {
          newMedia.add(m);
        }
      }
      enriched.add(
        PostEntity(
          localId: post.localId,
          postId: post.postId,
          userId: post.userId,
          author: post.author,
          content: post.content,
          createdAt: post.createdAt,
          updatedAt: post.updatedAt,
          visibility: post.visibility,
          postCode: post.postCode,
          image: post.image,
          media: newMedia,
          mediaIds: post.mediaIds,
          likesCount: post.likesCount,
          commentsCount: post.commentsCount,
        ),
      );
    }

    await _purgeOrphanFiles(mediaDir, keptPaths);

    final db = await DatabaseHelper.instance.database;
    final batch = db.batch();
    batch.delete('feed_posts');
    final fetchedAt = DateTime.now().toIso8601String();

    for (var i = 0; i < enriched.length; i++) {
      final post = enriched[i];
      final pid = post.postId;
      if (pid == null) continue;
      batch.insert('feed_posts', {
        'post_id': pid,
        'user_id': post.userId,
        'content': post.content,
        'created_at': post.createdAt,
        'updated_at': post.updatedAt,
        'visibility': post.visibility.toJson(),
        'post_code': post.postCode,
        'position': i,
        'media_json': _encodeMedia(post.media),
        'author_json': _encodeAuthor(post.author),
        'likes_count': post.likesCount,
        'comments_count': post.commentsCount,
        'fetched_at': fetchedAt,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);

    return enriched;
  }

  String? _encodeMedia(List<PostMediaItem>? media) {
    if (media == null || media.isEmpty) return null;
    return jsonEncode(media.map((m) => m.toJson()).toList());
  }

  String? _encodeAuthor(PostAuthor? author) {
    if (author == null) return null;
    return jsonEncode(author.toJson());
  }

  Future<List<PostEntity>> readCachedFeed() async {
    final db = await DatabaseHelper.instance.database;
    final rows = await db.query('feed_posts', orderBy: 'position ASC');
    return rows.map((row) {
      final mediaJson = row['media_json'] as String?;
      List<PostMediaItem>? media;
      if (mediaJson != null && mediaJson.isNotEmpty) {
        final list = jsonDecode(mediaJson) as List<dynamic>;
        media = list
            .map((e) => PostMediaItem.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      final likesRaw = row['likes_count'];
      final commentsRaw = row['comments_count'];
      final authorJson = row['author_json'] as String?;
      PostAuthor? author;
      if (authorJson != null && authorJson.isNotEmpty) {
        try {
          author = PostAuthor.fromJson(
            jsonDecode(authorJson) as Map<String, dynamic>,
          );
        } catch (_) {}
      }
      return PostEntity(
        localId: null,
        postId: row['post_id'] as String?,
        userId: row['user_id'] as String?,
        author: author,
        content: row['content'] as String,
        createdAt: row['created_at'] as String,
        updatedAt: row['updated_at'] as String?,
        visibility: PostVisibility.fromJson(row['visibility'] as String?),
        postCode: row['post_code'] as String?,
        image: null,
        media: media,
        likesCount: likesRaw is int
            ? likesRaw
            : (likesRaw is num ? likesRaw.toInt() : 0),
        commentsCount: commentsRaw is int
            ? commentsRaw
            : (commentsRaw is num ? commentsRaw.toInt() : 0),
      );
    }).toList();
  }

  Future<String?> _ensureImageCached(
    String url,
    Directory mediaDir,
    String documentsPath,
  ) async {
    final hash = sha256.convert(utf8.encode(url)).toString();
    final ext = _guessExtensionFromUrl(url);
    final relative = '$_feedMediaSubdir/$hash$ext';
    final file = File(p.join(documentsPath, relative));

    try {
      if (await file.exists()) {
        final len = await file.length();
        if (len > 0) {
          return relative;
        }
      }
    } catch (_) {}

    try {
      final response = await _dio.get<List<int>>(
        url,
        options: Options(
          responseType: ResponseType.bytes,
          receiveTimeout: _downloadTimeout,
        ),
      );
      final bytes = response.data;
      if (bytes == null || bytes.isEmpty) return null;

      await file.writeAsBytes(bytes, flush: true);
      return relative;
    } catch (_) {
      if (await file.exists()) {
        try {
          final len = await file.length();
          if (len > 0) return relative;
        } catch (_) {}
      }
      return null;
    }
  }

  String _guessExtensionFromUrl(String url) {
    final lower = url.toLowerCase();
    if (lower.contains('.png')) return '.png';
    if (lower.contains('.webp')) return '.webp';
    if (lower.contains('.gif')) return '.gif';
    return '.jpg';
  }

  Future<void> _purgeOrphanFiles(
    Directory mediaDir,
    Set<String> keptRelativePaths,
  ) async {
    if (!await mediaDir.exists()) return;
    await for (final entity in mediaDir.list()) {
      if (entity is! File) continue;
      final name = p.basename(entity.path);
      final rel = '$_feedMediaSubdir/$name';
      if (!keptRelativePaths.contains(rel)) {
        try {
          await entity.delete();
        } catch (_) {}
      }
    }
  }
}
