/// Подмена origin у presigned URL (S3/MinIO), если клиент должен ходить на другой host/port,
/// чем в строке с бэкенда (например эмулятор: `10.0.2.2` вместо `127.0.0.1`).
/// Path и query (включая подпись) не меняются.
String resolvePresignedUploadUrl(String presignedUrl, String origin) {
  final trimmed = origin.trim();
  if (trimmed.isEmpty) return presignedUrl;
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
