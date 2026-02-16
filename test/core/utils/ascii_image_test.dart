import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_social_network/core/utils/ascii_image.dart';

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  test(
    'imageToAsciiPng returns valid PNG preserving aspect ratio with max side pngMaxSide',
    () async {
      final inputImage = img.Image(width: 20, height: 20);
      for (int y = 0; y < 20; y++) {
        for (int x = 0; x < 20; x++) {
          inputImage.setPixelRgb(x, y, x * 12, y * 12, 128);
        }
      }
      final inputBytes = Uint8List.fromList(img.encodePng(inputImage));

      final pngBytes = await imageToAsciiPng(inputBytes);

      expect(pngBytes, isNotEmpty);

      final outputImage = img.decodeImage(pngBytes);
      expect(outputImage, isNotNull);
      final out = outputImage!;
      expect(out.width, pngMaxSide);
      expect(out.height, pngMaxSide);
    },
  );

  test('imageToAsciiPng throws on invalid image data', () async {
    final invalidBytes = Uint8List.fromList([1, 2, 3]);

    expect(imageToAsciiPng(invalidBytes), throwsA(anything));
  });
}
