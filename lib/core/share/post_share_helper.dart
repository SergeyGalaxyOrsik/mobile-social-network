import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'package:mobile_social_network/core/config/media_url_rewrite_config.dart';
import 'package:mobile_social_network/core/share/post_share_card_image.dart';
import 'package:mobile_social_network/features/posts/domain/entities/post_entity.dart';
import 'package:mobile_social_network/features/posts/domain/entities/post_media_item.dart';
import 'package:mobile_social_network/l10n/app_localizations.dart';

/// Resolves a path stored relative to app documents (same as feed local images).
Future<String?> resolvePostLocalMediaPath(String? relativePath) async {
  if (relativePath == null || relativePath.isEmpty) return null;
  final dir = await getApplicationDocumentsDirectory();
  return p.join(dir.path, relativePath);
}

/// Builds a PNG card for the post and opens the system share sheet with that file
/// only (no separate text intent), so targets like Instagram see a single image.
///
/// Instagram does not expose a public API for third-party Story publishing; the
/// user picks Instagram (Story or Feed) from the OS share targets.
final class PostShareHelper {
  PostShareHelper._();

  static Future<void> sharePost(
    BuildContext context,
    PostEntity post,
    AppLocalizations l10n, {
    required Future<String?> Function(String?) resolveImagePath,
    String? shareAuthorLabel,
  }) async {
    if (!context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    final failedMessage = l10n.postShareFailed;
    final String Function(String) resolveMediaUrl = () {
      try {
        final cfg = context.read<MediaUrlRewriteConfig>();
        return (String u) => cfg.resolve(u);
      } catch (_) {
        return (String u) => u;
      }
    }();
    final authorLine = _resolveAuthorLine(post, l10n, shareAuthorLabel);
    try {
      final photoBytes = await _loadFirstImageBytes(
        resolveMediaUrl,
        post,
        resolveImagePath,
      );
      if (!context.mounted) return;
      final tmp = await getTemporaryDirectory();
      final png = await PostShareCardImageBuilder.renderToPngFile(
        post: post,
        authorLine: authorLine,
        appFooter: l10n.appTitle,
        outputDirectory: tmp,
        photoBytes: photoBytes,
      );
      if (png == null) {
        throw StateError('renderToPngFile returned null');
      }
      if (!context.mounted) return;
      await SharePlus.instance.share(
        ShareParams(
          files: [
            XFile(png.path, mimeType: 'image/png'),
          ],
        ),
      );
    } catch (e, st) {
      debugPrint('PostShareHelper: $e\n$st');
      if (context.mounted) {
        messenger.showSnackBar(SnackBar(content: Text(failedMessage)));
      }
    }
  }

  static String _resolveAuthorLine(
    PostEntity post,
    AppLocalizations l10n,
    String? shareAuthorLabel,
  ) {
    final a = shareAuthorLabel?.trim();
    if (a != null && a.isNotEmpty) return a;
    final u = post.author?.username.trim();
    if (u != null && u.isNotEmpty) return u;
    return l10n.commentUserShort;
  }

  static Future<Uint8List?> _loadFirstImageBytes(
    String Function(String) resolveMediaUrl,
    PostEntity post,
    Future<String?> Function(String?) resolveImagePath,
  ) async {
    final media = post.media;
    if (media != null && media.isNotEmpty) {
      final image = _firstMatchingType(media, (t) => t.startsWith('image/'));
      if (image != null) {
        return _bytesForImageMedia(resolveMediaUrl, image, resolveImagePath);
      }
    }
    if (post.image != null && post.image!.isNotEmpty) {
      final local = await resolveImagePath(post.image);
      if (local != null && File(local).existsSync()) {
        return File(local).readAsBytes();
      }
    }
    return null;
  }

  static PostMediaItem? _firstMatchingType(
    List<PostMediaItem> items,
    bool Function(String type) predicate,
  ) {
    for (final m in items) {
      if (predicate(m.type)) return m;
    }
    return null;
  }

  static Future<Uint8List?> _bytesForImageMedia(
    String Function(String) resolveMediaUrl,
    PostMediaItem media,
    Future<String?> Function(String?) resolveImagePath,
  ) async {
    final rel = media.localRelativePath;
    if (rel != null && rel.isNotEmpty) {
      final path = await resolveImagePath(rel);
      if (path != null && File(path).existsSync()) {
        return File(path).readAsBytes();
      }
    }
    final resolvedUrl = resolveMediaUrl(media.url);
    if (resolvedUrl.isEmpty) return null;
    final r = await Dio().get<List<int>>(
      resolvedUrl,
      options: Options(responseType: ResponseType.bytes),
    );
    final raw = r.data;
    if (raw == null) return null;
    return Uint8List.fromList(raw);
  }
}
