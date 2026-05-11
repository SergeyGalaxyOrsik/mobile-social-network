import 'package:flutter/foundation.dart';

enum PushServerEvent { friendRequest, friendAdded, friendPost, unknown }

class ParsedPushMessage {
  const ParsedPushMessage({
    required this.event,
    required this.schemaVersion,
    required this.raw,
    this.requestId,
    this.fromUserId,
    this.fromUsername,
    this.peerUserId,
    this.peerUsername,
    this.postId,
    this.postCode,
    this.authorUserId,
    this.authorUsername,
  });

  final PushServerEvent event;
  final String schemaVersion;
  final Map<String, String> raw;

  final String? requestId;
  final String? fromUserId;
  final String? fromUsername;
  final String? peerUserId;
  final String? peerUsername;
  final String? postId;
  final String? postCode;
  final String? authorUserId;
  final String? authorUsername;

  static Map<String, String> _stringifyData(Map<String, dynamic> data) {
    return data.map((k, v) => MapEntry(k, v == null ? '' : v.toString()));
  }

  static ParsedPushMessage? tryParse(Map<String, dynamic> data) {
    final flat = _stringifyData(data);
    final eventRaw = flat['event'] ?? '';
    final event = switch (eventRaw) {
      'friend_request' => PushServerEvent.friendRequest,
      'friend_added' => PushServerEvent.friendAdded,
      'friend_post' => PushServerEvent.friendPost,
      _ => PushServerEvent.unknown,
    };
    if (event == PushServerEvent.unknown) {
      return null;
    }

    final schemaVersion = flat['schema_version'] ?? '1';
    if (schemaVersion != '1' && kDebugMode) {
      debugPrint('FCM: unsupported schema_version=$schemaVersion (proceeding)');
    }

    switch (event) {
      case PushServerEvent.friendRequest:
        return ParsedPushMessage(
          event: event,
          schemaVersion: schemaVersion,
          raw: flat,
          requestId: _uuid(flat['request_id']),
          fromUserId: _uuid(flat['from_user_id']),
          fromUsername: _nonEmpty(flat['from_username']),
        );
      case PushServerEvent.friendAdded:
        return ParsedPushMessage(
          event: event,
          schemaVersion: schemaVersion,
          raw: flat,
          peerUserId: _uuid(flat['peer_user_id']),
          peerUsername: _nonEmpty(flat['peer_username']),
        );
      case PushServerEvent.friendPost:
        return ParsedPushMessage(
          event: event,
          schemaVersion: schemaVersion,
          raw: flat,
          postId: _uuid(flat['post_id']),
          postCode: _nonEmpty(flat['post_code']),
          authorUserId: _uuid(flat['author_user_id']),
          authorUsername: _nonEmpty(flat['author_username']),
        );
      case PushServerEvent.unknown:
        return null;
    }
  }

  static String? _nonEmpty(String? s) {
    if (s == null || s.isEmpty) return null;
    return s;
  }

  static String? _uuid(String? s) => _nonEmpty(s);
}
