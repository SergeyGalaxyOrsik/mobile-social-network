import 'package:equatable/equatable.dart';

class ChatMediaAttachment extends Equatable {
  const ChatMediaAttachment({
    required this.mediaId,
    required this.url,
    this.contentType,
  });

  final String mediaId;
  final String url;
  final String? contentType;

  @override
  List<Object?> get props => [mediaId, url, contentType];
}
