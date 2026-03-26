import 'dart:io';

import 'package:flutter/material.dart';

Widget buildUserAvatarImage({required String? avatarUrl, double size = 40}) {
  if (avatarUrl == null || avatarUrl.isEmpty) {
    return Icon(Icons.person, size: size);
  }
  if (avatarUrl.startsWith('http://') || avatarUrl.startsWith('https://')) {
    return Image.network(
      avatarUrl,
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
