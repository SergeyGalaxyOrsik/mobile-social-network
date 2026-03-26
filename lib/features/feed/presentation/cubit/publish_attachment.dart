class PublishAttachment {
  const PublishAttachment({
    required this.path,
    required this.contentType,
    required this.sizeBytes,
  });

  final String path;
  final String contentType;
  final int sizeBytes;
}
