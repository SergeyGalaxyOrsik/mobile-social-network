import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_social_network/core/utils/presigned_upload_url.dart';

void main() {
  test('presigned URL is not rewritten (signature bound to host)', () {
    const url =
        'http://127.0.0.1:9000/bucket/key.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Signature=abc';
    expect(isAwsSigV4PresignedUrl(url), isTrue);
    expect(
      resolvePresignedUploadUrl(url, 'http://10.0.2.2:9000'),
      url,
    );
  });

  test('public object URL is rewritten when origin set', () {
    const url = 'http://127.0.0.1:9000/tomo-media/media/u/m.jpg';
    expect(isAwsSigV4PresignedUrl(url), isFalse);
    expect(
      resolvePresignedUploadUrl(url, 'http://10.0.2.2:9000'),
      'http://10.0.2.2:9000/tomo-media/media/u/m.jpg',
    );
  });
}
