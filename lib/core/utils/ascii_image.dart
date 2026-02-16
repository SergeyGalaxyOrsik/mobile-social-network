import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter_image_filters/flutter_image_filters.dart';

/// Maximum length of the longer side of the exported image (keeps aspect ratio).
/// Higher value gives finer halftone detail.
const int pngMaxSide = 800;

/// Applies halftone filter to an image and returns PNG bytes. Output size keeps the original aspect ratio,
/// with the longer side capped at [pngMaxSide].
///
/// [imageBytes] — raw image data (e.g. PNG, JPEG).
///
/// Returns PNG bytes. Requires Flutter bindings (e.g. call after [WidgetsFlutterBinding.ensureInitialized]).
Future<Uint8List> imageToAsciiPng(Uint8List imageBytes) async {
  final texture = await TextureSource.fromMemory(imageBytes);
  final configuration = HalftoneShaderConfiguration();
  configuration.fractionalWidthOfPixel = 0.004;
  final w = texture.width.toDouble();
  final h = texture.height.toDouble();
  final maxSide = pngMaxSide.toDouble();
  final scale = w > h ? maxSide / w : maxSide / h;
  final outW = (w * scale).round();
  final outH = (h * scale).round();
  final size = ui.Size(outW.toDouble(), outH.toDouble());
  final image = await configuration.export(texture, size);

  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  if (byteData == null) {
    throw StateError('Failed to encode PNG');
  }
  return byteData.buffer.asUint8List(
    byteData.offsetInBytes,
    byteData.lengthInBytes,
  );
}
