/// Builds the Socket.IO URL for namespace `/chat` from the same API base as [Dio].
///
/// Uses [Uri.origin] so a REST base like `https://host/api/v1` still maps to `https://host`.
String resolveChatSocketUri(String apiBaseUrl) {
  final trimmed = apiBaseUrl.trim();
  if (trimmed.isEmpty) {
    throw ArgumentError.value(apiBaseUrl, 'apiBaseUrl', 'must not be empty');
  }
  final origin = Uri.parse(trimmed).origin;
  final base = origin.endsWith('/') ? origin.substring(0, origin.length - 1) : origin;
  return '$base/chat';
}
