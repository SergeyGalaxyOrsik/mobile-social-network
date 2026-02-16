import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

/// Saves post ASCII PNG to app documents under [posts/<noteId>.png]
/// and returns the relative path for storing in the database.
Future<String> savePostImage(int noteId, Uint8List pngBytes) async {
  final dir = await getApplicationDocumentsDirectory();
  final postsDir = path.join(dir.path, 'posts');
  final dirEntity = await Directory(postsDir).create(recursive: true);
  final filePath = path.join(dirEntity.path, '$noteId.png');
  final file = File(filePath);
  await file.writeAsBytes(pngBytes);
  return 'posts/$noteId.png';
}
