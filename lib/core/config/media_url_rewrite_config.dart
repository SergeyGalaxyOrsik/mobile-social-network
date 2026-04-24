import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mobile_social_network/core/utils/presigned_upload_url.dart';

/// Подмена origin у **публичных** URL медиа/аватаров (см. [resolvePresignedUploadUrl]).
/// Presigned URL с `X-Amz-Signature` не переписываются.
/// В dev на Android-эмуляторе для **PUT** к MinIO нужен `adb reverse tcp:9000 tcp:9000`
/// или корректный публичный host при подписи на бэкенде.
class MediaUrlRewriteConfig {
  const MediaUrlRewriteConfig(this.rewriteOrigin);

  final String rewriteOrigin;

  String resolve(String url) {
    final t = rewriteOrigin.trim();
    if (t.isEmpty) return url;
    if (url.trim().isEmpty) return url;
    return resolvePresignedUploadUrl(url, t);
  }
}

extension MediaUrlRewriteContextX on BuildContext {
  String resolveMediaDisplayUrl(String url) {
    try {
      return read<MediaUrlRewriteConfig>().resolve(url);
    } catch (_) {
      return url;
    }
  }
}
