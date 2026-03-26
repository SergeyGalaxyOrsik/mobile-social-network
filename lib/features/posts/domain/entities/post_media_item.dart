class PostMediaItem {
  const PostMediaItem({
    required this.mediaId,
    required this.type,
    required this.url,
    this.localRelativePath,
  });

  final String mediaId;
  final String type;
  final String url;
  final String? localRelativePath;

  Map<String, dynamic> toJson() => {
    'media_id': mediaId,
    'type': type,
    'url': url,
    if (localRelativePath != null) 'local_path': localRelativePath,
  };

  factory PostMediaItem.fromJson(Map<String, dynamic> json) {
    return PostMediaItem(
      mediaId: json['media_id'] as String,
      type: json['type'] as String,
      url: json['url'] as String,
      localRelativePath: json['local_path'] as String?,
    );
  }
}
