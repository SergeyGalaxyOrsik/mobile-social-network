import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_image_filters/flutter_image_filters.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Longer side cap for GPU filter export (memory / speed).
const int kPublishFilterMaxSide = 2048;

/// Same order of magnitude as [ascii_image] halftone; tune for dot size on export.
const double kPublishHalftoneFractionalWidth = 0.004;

/// Applies halftone (`shaders/halftone.frag`) and writes PNG to a temp file.
/// Returns [path] unchanged on web, for non-images, on failure, or if filters are unavailable.
Future<String> prepareImagePathForPublish(String path) async {
  final mime = lookupMimeType(path) ?? '';
  if (kIsWeb) return path;
  if (!_shouldApplyRasterFilter(mime)) return path;

  try {
    // Use the app’s [shaders/halftone.frag] from pubspec, not only the package copy.
    FlutterImageFilters.register<HalftoneShaderConfiguration>(
      () => ui.FragmentProgram.fromAsset('shaders/halftone.frag'),
      override: true,
    );
    await FlutterImageFilters.prepare();
    final texture = await TextureSource.fromFile(File(path));
    final configuration = HalftoneShaderConfiguration();
    configuration.fractionalWidthOfPixel = kPublishHalftoneFractionalWidth;

    final w = texture.width.toDouble();
    final h = texture.height.toDouble();
    final maxSide = kPublishFilterMaxSide.toDouble();
    final maxDim = w > h ? w : h;
    final scale = maxDim > maxSide ? maxSide / maxDim : 1.0;
    final outW = (w * scale).round();
    final outH = (h * scale).round();
    final size = ui.Size(outW.toDouble(), outH.toDouble());

    final image = await configuration.export(texture, size);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) return path;

    final bytes = byteData.buffer.asUint8List(
      byteData.offsetInBytes,
      byteData.lengthInBytes,
    );

    final tempDir = await getTemporaryDirectory();
    final outPath = p.join(
      tempDir.path,
      'publish_filter_${DateTime.now().millisecondsSinceEpoch}.png',
    );
    await File(outPath).writeAsBytes(bytes);
    return outPath;
  } catch (_) {
    return path;
  }
}

bool _shouldApplyRasterFilter(String mime) {
  if (mime.startsWith('video/')) return false;
  if (mime == 'image/gif') return false;
  return mime.startsWith('image/');
}
