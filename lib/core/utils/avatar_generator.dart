import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

const int _gridSize = 12;
const int _outputSize = 256;

/// Key colors for avatar (RGB): #FA4300, #00D9FA, #00FA73.
const List<(int r, int g, int b)> _keyColors = [
  (250, 67, 0), // #FA4300
  (0, 217, 250), // #00D9FA
  (0, 250, 115), // #00FA73
];

const int _backgroundR = 240;
const int _backgroundG = 240;
const int _backgroundB = 240;

/// Generates a deterministic avatar image from [nickname] and saves it to [filePath].
/// Returns [filePath] on success.
///
/// Algorithm: SHA-256(nickname) → one of 3 key colors + 8×8 grid (left half from
/// hash bits, mirrored to right), scaled to [_outputSize]×[_outputSize] PNG.
Future<String> generateAndSaveAvatar(String nickname, String filePath) async {
  debugPrint(
    '[AvatarGenerator] Generating avatar: nickname=$nickname, filePath=$filePath',
  );
  final bytes = _generateAvatarPng(nickname);
  final file = File(filePath);
  await file.parent.create(recursive: true);
  await file.writeAsBytes(bytes);
  debugPrint(
    '[AvatarGenerator] Avatar file written: path=$filePath, size=${bytes.length} bytes',
  );
  return filePath;
}

Uint8List _generateAvatarPng(String nickname) {
  final hashBytes = sha256.convert(utf8.encode(nickname)).bytes;
  final (r, g, b) =
      _keyColors[hashBytes.isNotEmpty ? hashBytes[0] % _keyColors.length : 0];

  final cellSize = _outputSize ~/ _gridSize;
  final image = img.Image(width: _outputSize, height: _outputSize);
  image.clear(img.ColorRgb8(_backgroundR, _backgroundG, _backgroundB));

  final halfCols = _gridSize ~/ 2;
  for (int row = 0; row < _gridSize; row++) {
    for (int col = 0; col < halfCols; col++) {
      final bitIndex = row * halfCols + col;
      final byteIndex = bitIndex ~/ 8;
      final bitMask = 1 << (7 - (bitIndex % 8));
      final on =
          byteIndex < hashBytes.length && (hashBytes[byteIndex] & bitMask) != 0;

      if (on) {
        _fillCell(image, row, col, r, g, b, cellSize);
        _fillCell(image, row, _gridSize - 1 - col, r, g, b, cellSize);
      }
    }
  }

  return img.encodePng(image);
}

void _fillCell(
  img.Image image,
  int gridRow,
  int gridCol,
  int r,
  int g,
  int b,
  int cellSize,
) {
  final x0 = gridCol * cellSize;
  final y0 = gridRow * cellSize;
  final x1 = x0 + cellSize;
  final y1 = y0 + cellSize;
  for (int y = y0; y < y1 && y < image.height; y++) {
    for (int x = x0; x < x1 && x < image.width; x++) {
      final pixel = image.getPixel(x, y);
      pixel.r = r;
      pixel.g = g;
      pixel.b = b;
    }
  }
}
