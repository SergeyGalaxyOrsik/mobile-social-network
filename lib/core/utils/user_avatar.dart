import 'dart:io';

import 'package:flutter/material.dart';

import 'package:mobile_social_network/core/config/media_url_rewrite_config.dart';

Widget buildUserAvatarImage({
  required String? avatarUrl,
  double size = 40,
  BuildContext? mediaRewriteContext,
}) {
  if (avatarUrl == null || avatarUrl.isEmpty) {
    return Icon(Icons.person, size: size);
  }
  if (avatarUrl.startsWith('http://') || avatarUrl.startsWith('https://')) {
    final resolved = mediaRewriteContext != null
        ? mediaRewriteContext.resolveMediaDisplayUrl(avatarUrl)
        : avatarUrl;
    return Image.network(
      resolved,
      width: size,
      height: size,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Icon(Icons.person, size: size),
    );
  }
  final file = File(avatarUrl);
  if (!file.existsSync()) {
    return Icon(Icons.person, size: size);
  }
  return Image.file(
    file,
    width: size,
    height: size,
    fit: BoxFit.cover,
    errorBuilder: (_, __, ___) => Icon(Icons.person, size: size),
  );
}
