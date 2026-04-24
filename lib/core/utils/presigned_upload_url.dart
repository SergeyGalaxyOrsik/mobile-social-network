/// Подмена origin у **публичных** URL (без SigV4), например картинки в ленте/чате на эмуляторе.
///
/// **Presigned PUT** (`X-Amz-Signature` в query) менять нельзя: подпись считается для
/// конкретного Host; смена `127.0.0.1` → `10.0.2.2` даёт отказ MinIO/S3. Для загрузки с
/// эмулятора используйте `adb reverse tcp:9000 tcp:9000` или публичный endpoint на бэке.
bool isAwsSigV4PresignedUrl(String url) {
  final u = Uri.tryParse(url);
  if (u == null || !u.hasQuery) return false;
  final q = u.query;
  return q.contains('X-Amz-Signature') || q.contains('X-Amz-Algorithm=');
}

/// Подмена origin, если [origin] задан и URL **не** presigned SigV4.
String resolvePresignedUploadUrl(String presignedUrl, String origin) {
  final trimmed = origin.trim();
  if (trimmed.isEmpty) return presignedUrl;
  if (isAwsSigV4PresignedUrl(presignedUrl)) {
    return presignedUrl;
  }
  final u = Uri.parse(presignedUrl);
  final o = Uri.parse(trimmed);
  if (!o.hasScheme || o.host.isEmpty) return presignedUrl;
  return Uri(
    scheme: o.scheme,
    host: o.host,
    port: o.hasPort ? o.port : u.port,
    path: u.path,
    query: u.hasQuery ? u.query : null,
    fragment: u.hasFragment ? u.fragment : null,
  ).toString();
}
