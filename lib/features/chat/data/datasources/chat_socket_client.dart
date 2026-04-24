import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import 'package:mobile_social_network/features/chat/data/mappers/chat_dto_mapper.dart';
import 'package:mobile_social_network/features/chat/data/models/chat_api_models.dart';
import 'package:mobile_social_network/features/chat/domain/entities/direct_message.dart';
import 'package:mobile_social_network/features/chat/domain/entities/direct_message_deleted.dart';

dynamic _unwrapAckArg(dynamic arg) {
  if (arg is List && arg.isNotEmpty) {
    return arg.first;
  }
  return arg;
}

Map<String, dynamic>? _asStringKeyedMap(dynamic v) {
  if (v is Map<String, dynamic>) return v;
  if (v is Map) {
    return v.map((k, val) => MapEntry(k.toString(), val));
  }
  return null;
}

bool _looksLikeErrorMap(Map<String, dynamic> m) {
  if (m.containsKey('message_id')) return false;
  final inner = m['message'];
  if (inner is Map && inner['message_id'] != null) return false;
  if (m.containsKey('conversation_id') && m['message_id'] == null && inner == null) {
    return false;
  }
  final code = m['code'];
  final err = m['error'];
  if (code != null || err != null) return true;
  final message = m['message'];
  if (message is String && message.toLowerCase().contains('not available')) {
    return true;
  }
  return false;
}

/// Socket.IO client for namespace `/chat` ([docs/API_CHAT.md](docs/API_CHAT.md)).
class ChatSocketClient {
  ChatSocketClient({
    required this.socketUri,
    required this.accessToken,
  });

  final String socketUri;
  final String? Function() accessToken;

  io.Socket? _socket;
  final _incoming = StreamController<DirectMessage>.broadcast();
  final _incomingDeletions =
      StreamController<DirectMessageDeleted>.broadcast();

  Stream<DirectMessage> get incomingMessages => _incoming.stream;

  Stream<DirectMessageDeleted> get incomingMessageDeletions =>
      _incomingDeletions.stream;

  bool get isConnected => _socket?.connected == true;

  void _log(String msg) {
    if (kDebugMode) {
      debugPrint('[ChatSocket] $msg');
    }
  }

  void _onDirectMessage(dynamic data) {
    final map = _asStringKeyedMap(data);
    if (map == null) return;
    final nested = map['message'];
    Map<String, dynamic>? messageMap;
    if (nested is Map<String, dynamic>) {
      messageMap = nested;
    } else if (nested is Map) {
      messageMap = nested.map((k, v) => MapEntry(k.toString(), v));
    } else if (map.containsKey('message_id')) {
      messageMap = map;
    }
    if (messageMap == null) return;
    try {
      final entity = DirectMessageDto.fromJson(messageMap).toEntity();
      if (entity.messageId.isEmpty) return;
      _incoming.add(entity);
    } catch (e, st) {
      _log('direct:message parse error: $e $st');
    }
  }

  void _onDirectMessageDeleted(dynamic data) {
    final map = _asStringKeyedMap(data);
    if (map == null) return;
    final cid = map['conversation_id'] as String?;
    final mid = map['message_id'] as String?;
    if (cid == null || mid == null || cid.isEmpty || mid.isEmpty) return;
    _incomingDeletions.add(
      DirectMessageDeleted(conversationId: cid, messageId: mid),
    );
  }

  Future<void> connect() async {
    final token = accessToken();
    if (token == null || token.isEmpty) {
      _log('skip connect: no token');
      return;
    }
    disconnect();
    final socket = io.io(
      socketUri,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .enableForceNew()
          .setAuth({'token': token})
          .build(),
    );
    _socket = socket;
    socket.on('direct:message', _onDirectMessage);
    socket.on('direct:message_deleted', _onDirectMessageDeleted);
    socket.onConnect((_) => _log('connected'));
    socket.onConnectError((dynamic e) => _log('connect_error: $e'));
    socket.onDisconnect((_) => _log('disconnected'));
    socket.connect();
    await _waitConnectedOrError(socket);
  }

  Future<void> _waitConnectedOrError(io.Socket socket) {
    if (socket.connected) return Future.value();
    final completer = Completer<void>();
    late void Function(dynamic) onErr;
    late void Function(dynamic) onOk;
    onErr = (dynamic e) {
      socket.off('connect', onOk);
      socket.off('connect_error', onErr);
      if (!completer.isCompleted) {
        completer.completeError(e ?? StateError('connect_error'));
      }
    };
    onOk = (_) {
      socket.off('connect', onOk);
      socket.off('connect_error', onErr);
      if (!completer.isCompleted) completer.complete();
    };
    socket.once('connect', onOk);
    socket.once('connect_error', onErr);
    return completer.future.timeout(
      const Duration(seconds: 20),
      onTimeout: () {
        socket.off('connect', onOk);
        socket.off('connect_error', onErr);
        if (!completer.isCompleted) {
          completer.completeError(TimeoutException('Socket connect'));
        }
      },
    );
  }

  void disconnect() {
    final s = _socket;
    _socket = null;
    if (s != null) {
      s.off('direct:message', _onDirectMessage);
      s.off('direct:message_deleted', _onDirectMessageDeleted);
      s.disconnect();
      s.dispose();
    }
  }

  Future<String?> subscribePeer(String peerUserId) async {
    final s = _socket;
    if (s == null || !s.connected) return null;
    final completer = Completer<String?>();
    s.emitWithAck(
      'direct:subscribe',
      {'peer_user_id': peerUserId},
      ack: (dynamic arg, [dynamic __]) {
        if (completer.isCompleted) return;
        try {
          final data = _unwrapAckArg(arg);
          final map = _asStringKeyedMap(data);
          if (map != null && _looksLikeErrorMap(map)) {
            completer.completeError(
              StateError(map['message']?.toString() ?? 'subscribe failed'),
            );
            return;
          }
          final id = map?['conversation_id'] as String?;
          completer.complete(id);
        } catch (e) {
          completer.completeError(e);
        }
      },
    );
    try {
      return await completer.future.timeout(const Duration(seconds: 12));
    } on TimeoutException {
      return null;
    }
  }

  /// Returns null if not connected or ack indicates failure (caller uses REST).
  Future<DirectMessage?> trySend({
    required String peerUserId,
    String? body,
    List<String> mediaIds = const [],
  }) async {
    final s = _socket;
    if (s == null || !s.connected) return null;
    final payload = <String, dynamic>{
      'peer_user_id': peerUserId,
      'media_ids': mediaIds,
    };
    final trimmed = body?.trim();
    if (trimmed != null && trimmed.isNotEmpty) {
      payload['body'] = trimmed;
    }
    final completer = Completer<DirectMessage?>();
    s.emitWithAck(
      'direct:send',
      payload,
      ack: (dynamic arg, [dynamic __]) {
        if (completer.isCompleted) return;
        try {
          final data = _unwrapAckArg(arg);
          final map = _asStringKeyedMap(data);
          if (map != null && _looksLikeErrorMap(map)) {
            completer.completeError(
              StateError(map['message']?.toString() ?? 'send failed'),
            );
            return;
          }
          final msgMap = map?['message'];
          Map<String, dynamic>? parsed;
          if (msgMap is Map<String, dynamic>) {
            parsed = msgMap;
          } else if (msgMap is Map) {
            parsed = msgMap.map((k, v) => MapEntry(k.toString(), v));
          } else if (map != null && map.containsKey('message_id')) {
            parsed = map;
          }
          if (parsed == null) {
            completer.complete(null);
            return;
          }
          completer.complete(DirectMessageDto.fromJson(parsed).toEntity());
        } catch (e) {
          completer.completeError(e);
        }
      },
    );
    try {
      return await completer.future.timeout(const Duration(seconds: 30));
    } on TimeoutException {
      return null;
    }
  }
}
