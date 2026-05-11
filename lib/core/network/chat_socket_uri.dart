String resolveChatSocketUri(String apiBaseUrl) {
  final trimmed = apiBaseUrl.trim();
  if (trimmed.isEmpty) {
    throw ArgumentError.value(apiBaseUrl, 'apiBaseUrl', 'must not be empty');
  }
  final origin = Uri.parse(trimmed).origin;
  final base = origin.endsWith('/')
      ? origin.substring(0, origin.length - 1)
      : origin;
  return '$base/chat';
}
