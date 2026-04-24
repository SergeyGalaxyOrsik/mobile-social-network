import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/painting.dart';

import 'package:mobile_social_network/features/posts/domain/entities/post_entity.dart';

/// Renders a single shareable PNG (post as a designed card).
final class PostShareCardImageBuilder {
  PostShareCardImageBuilder._();

  static const double _width = 1080;
  static const double _pad = 56;
  static const double _maxHeight = 1920;
  static const double _maxImageBlockHeight = 720;

  static Future<File?> renderToPngFile({
    required PostEntity post,
    required String authorLine,
    required String appFooter,
    required Directory outputDirectory,
    Uint8List? photoBytes,
  }) async {
    ui.Image? decoded;
    if (photoBytes != null && photoBytes.isNotEmpty) {
      decoded = await _decodeImage(photoBytes);
    }
    try {
      final body = post.content.trim();
      final dateLine = post.createdAt.trim();
      final code = post.postCode?.trim();

      final contentW = _width - 2 * _pad;
      final bodyPainter = TextPainter(
        text: TextSpan(
          text: body.isEmpty ? ' ' : body,
          style: const TextStyle(
            color: Color(0xFF1C1B1F),
            fontSize: 34,
            height: 1.35,
          ),
        ),
        textDirection: TextDirection.ltr,
        maxLines: 14,
        ellipsis: '…',
      )..layout(maxWidth: contentW);

      final authorPainter = TextPainter(
        text: TextSpan(
          text: authorLine.isEmpty ? '—' : authorLine,
          style: const TextStyle(
            color: Color(0xFF1C1B1F),
            fontSize: 44,
            fontWeight: FontWeight.w600,
            height: 1.15,
          ),
        ),
        textDirection: TextDirection.ltr,
        maxLines: 1,
        ellipsis: '…',
      )..layout(maxWidth: contentW);

      final datePainter = TextPainter(
        text: TextSpan(
          text: dateLine.isEmpty ? ' ' : dateLine,
          style: const TextStyle(
            color: Color(0xFF49454F),
            fontSize: 26,
            height: 1.2,
          ),
        ),
        textDirection: TextDirection.ltr,
        maxLines: 1,
        ellipsis: '…',
      )..layout(maxWidth: contentW);

      TextPainter? codePainter;
      if (code != null && code.isNotEmpty) {
        codePainter = TextPainter(
          text: TextSpan(
            text: code,
            style: const TextStyle(
              color: Color(0xFF49454F),
              fontSize: 24,
              height: 1.25,
            ),
          ),
          textDirection: TextDirection.ltr,
          maxLines: 2,
          ellipsis: '…',
        )..layout(maxWidth: contentW);
      }

      final footerPainter = TextPainter(
        text: TextSpan(
          text: appFooter,
          style: const TextStyle(
            color: Color(0xFF79747E),
            fontSize: 22,
            height: 1.2,
          ),
        ),
        textDirection: TextDirection.ltr,
        maxLines: 1,
        ellipsis: '…',
      )..layout(maxWidth: contentW);

      var imageDrawH = 0.0;
      if (decoded != null) {
        final iw = decoded.width.toDouble();
        final ih = decoded.height.toDouble();
        if (iw > 0 && ih > 0) {
          final boxW = contentW;
          imageDrawH = boxW * ih / iw;
          if (imageDrawH > _maxImageBlockHeight) {
            imageDrawH = _maxImageBlockHeight;
          }
        }
      }

      double totalForImageH(double imgH) {
        var t = _pad +
            authorPainter.height +
            18 +
            datePainter.height +
            28 +
            bodyPainter.height;
        if (decoded != null && imgH > 0) {
          t += 32 + imgH;
        }
        if (codePainter != null) {
          t += 28 + codePainter.height;
        }
        t += 36 + footerPainter.height + _pad;
        return t;
      }

      if (totalForImageH(imageDrawH) > _maxHeight &&
          decoded != null &&
          imageDrawH > 200) {
        var h = imageDrawH;
        while (totalForImageH(h) > _maxHeight && h > 200) {
          h -= 24;
        }
        imageDrawH = h;
      }

      final heightI =
          totalForImageH(imageDrawH).ceil().clamp(720, _maxHeight.round());

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final bg = Paint()..color = const Color(0xFFFEF7FF);
      canvas.drawRect(Rect.fromLTWH(0, 0, _width, heightI.toDouble()), bg);

      final border = Paint()
        ..color = const Color(0xFFE7E0EC)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(12, 12, _width - 24, heightI - 24),
          const Radius.circular(20),
        ),
        border,
      );

      var y = _pad;
      authorPainter.paint(canvas, Offset(_pad, y));
      y += authorPainter.height + 18;
      datePainter.paint(canvas, Offset(_pad, y));
      y += datePainter.height + 28;
      bodyPainter.paint(canvas, Offset(_pad, y));
      y += bodyPainter.height;

      if (decoded != null && imageDrawH > 0) {
        y += 32;
        final boxW = contentW;
        final dst = Rect.fromLTWH(_pad, y, boxW, imageDrawH);
        final rrect = RRect.fromRectAndRadius(dst, const Radius.circular(12));
        canvas.save();
        canvas.clipRRect(rrect);
        canvas.drawImageRect(
          decoded,
          Rect.fromLTWH(
            0,
            0,
            decoded.width.toDouble(),
            decoded.height.toDouble(),
          ),
          dst,
          Paint()..filterQuality = FilterQuality.medium,
        );
        canvas.restore();
        y += imageDrawH;
      }

      if (codePainter != null) {
        y += 28;
        codePainter.paint(canvas, Offset(_pad, y));
        y += codePainter.height;
      }

      y += 36;
      footerPainter.paint(canvas, Offset(_pad, y));

      final picture = recorder.endRecording();
      final image = await picture.toImage(_width.round(), heightI);
      try {
        final byteData =
            await image.toByteData(format: ui.ImageByteFormat.png);
        if (byteData == null) return null;
        final bytes = byteData.buffer.asUint8List(
          byteData.offsetInBytes,
          byteData.lengthInBytes,
        );
        final id = (post.postId ?? post.localId?.toString() ?? 'local')
            .replaceAll(RegExp(r'[^\w\-]+'), '_');
        final out = File('${outputDirectory.path}/post_share_$id.png');
        await out.writeAsBytes(bytes, flush: true);
        return out;
      } finally {
        image.dispose();
      }
    } finally {
      decoded?.dispose();
    }
  }

  static Future<ui.Image?> _decodeImage(Uint8List bytes) async {
    final codec = await ui.instantiateImageCodec(
      bytes,
      targetWidth: 2048,
    );
    final frame = await codec.getNextFrame();
    return frame.image;
  }
}
