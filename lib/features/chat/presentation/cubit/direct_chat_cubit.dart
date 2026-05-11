import 'dart:async';
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mime/mime.dart';

import 'package:mobile_social_network/core/constants/media_upload_constants.dart';
import 'package:mobile_social_network/core/network/api_exception.dart';
import 'package:mobile_social_network/features/chat/domain/entities/direct_message.dart';
import 'package:mobile_social_network/features/chat/domain/entities/direct_message_deleted.dart';
import 'package:mobile_social_network/features/chat/domain/repositories/chat_repository.dart';
import 'package:mobile_social_network/features/chat/presentation/cubit/direct_chat_state.dart';
import 'package:mobile_social_network/features/media/data/media_upload_service.dart';

class DirectChatCubit extends Cubit<DirectChatState> {
  DirectChatCubit({
    required ChatRepository repository,
    required MediaUploadService mediaUploadService,
    required String peerUserId,
    required String currentUserId,
    String? peerDisplayName,
  }) : _repository = repository,
       _mediaUpload = mediaUploadService,
       super(
         DirectChatState(
           peerUserId: peerUserId,
           currentUserId: currentUserId,
           peerDisplayName: peerDisplayName,
         ),
       ) {
    _subscription = _repository.incomingDirectMessages.listen(
      _onIncoming,
      onError: (_) {},
    );
    _deletionSubscription = _repository.incomingDirectMessageDeletions.listen(
      _onMessageDeleted,
      onError: (_) {},
    );
  }

  final ChatRepository _repository;
  final MediaUploadService _mediaUpload;
  StreamSubscription<DirectMessage>? _subscription;
  StreamSubscription<DirectMessageDeleted>? _deletionSubscription;
  final Set<String> _readMessageIds = <String>{};

  bool _belongsToThread(DirectMessage m) {
    if (state.conversationId != null &&
        state.conversationId!.isNotEmpty &&
        m.conversationId.isNotEmpty) {
      return m.conversationId == state.conversationId;
    }
    return m.senderId == state.peerUserId || m.senderId == state.currentUserId;
  }

  void _onIncoming(DirectMessage m) {
    if (!_belongsToThread(m)) return;
    if (state.messages.any((x) => x.messageId == m.messageId)) return;
    emit(state.copyWith(messages: [...state.messages, m]));
    _markIncomingRead([m]);
  }

  void _markIncomingRead(Iterable<DirectMessage> messages) {
    for (final message in messages) {
      if (message.senderId != state.peerUserId) continue;
      if (!_readMessageIds.add(message.messageId)) continue;
      Future(() async {
        try {
          await _repository.markMessageRead(
            messageId: message.messageId,
            peerUserId: state.peerUserId,
          );
        } catch (_) {
          _readMessageIds.remove(message.messageId);
        }
      });
    }
  }

  void _onMessageDeleted(DirectMessageDeleted e) {
    if (!state.messages.any((m) => m.messageId == e.messageId)) return;
    if (state.conversationId != null &&
        state.conversationId!.isNotEmpty &&
        e.conversationId != state.conversationId) {
      return;
    }
    emit(
      state.copyWith(
        messages: state.messages
            .where((m) => m.messageId != e.messageId)
            .toList(),
      ),
    );
  }

  Future<void> open() async {
    emit(state.copyWith(loading: true, clearError: true));
    try {
      final page = await _repository.fetchMessages(
        state.peerUserId,
        limit: DirectChatState.pageSize,
        offset: 0,
      );
      final chronological = page.reversed.toList();
      String? convId;
      if (chronological.isNotEmpty) {
        convId = chronological.last.conversationId;
      }
      emit(
        state.copyWith(
          messages: chronological,
          conversationId: convId,
          loading: false,
          hasMoreOlder: page.length >= DirectChatState.pageSize,
        ),
      );
      _markIncomingRead(chronological);
      final subId = await _repository.subscribePeer(state.peerUserId);
      if (subId != null && subId.isNotEmpty) {
        emit(state.copyWith(conversationId: subId));
      }
    } on ApiException catch (e) {
      emit(state.copyWith(loading: false, lastError: e.userMessage));
    } catch (e) {
      emit(state.copyWith(loading: false, lastError: e.toString()));
    }
  }

  Future<void> loadOlder() async {
    if (!state.canLoadMoreOlder || state.loadingMore) return;
    emit(state.copyWith(loadingMore: true, clearError: true));
    try {
      final page = await _repository.fetchMessages(
        state.peerUserId,
        limit: DirectChatState.pageSize,
        offset: state.messages.length,
      );
      if (page.isEmpty) {
        emit(state.copyWith(loadingMore: false, hasMoreOlder: false));
        return;
      }
      final older = page.reversed.toList();
      final merged = [...older, ...state.messages];
      emit(
        state.copyWith(
          messages: merged,
          loadingMore: false,
          hasMoreOlder: page.length >= DirectChatState.pageSize,
        ),
      );
    } on ApiException catch (e) {
      emit(state.copyWith(loadingMore: false, lastError: e.userMessage));
    } catch (e) {
      emit(state.copyWith(loadingMore: false, lastError: e.toString()));
    }
  }

  void setPendingMediaPaths(List<String> paths) {
    emit(
      state.copyWith(
        pendingMediaPaths: paths
            .take(MediaUploadConstants.maxMediaPerPost)
            .toList(),
      ),
    );
  }

  void clearPendingMedia() {
    emit(state.copyWith(pendingMediaPaths: []));
  }

  Future<void> sendText(String raw) async {
    final text = raw.trim();
    final paths = state.pendingMediaPaths;
    if (text.isEmpty && paths.isEmpty) return;
    emit(state.copyWith(sending: true, clearError: true));
    try {
      final mediaIds = <String>[];
      for (final path in paths) {
        final f = File(path);
        final size = await f.length();
        if (size > MediaUploadConstants.maxFileBytes) {
          emit(state.copyWith(sending: false, lastError: 'file_too_large'));
          return;
        }
        final mime = lookupMimeType(path) ?? 'application/octet-stream';
        if (!mime.startsWith('image/') && !mime.startsWith('video/')) {
          emit(state.copyWith(sending: false, lastError: 'chat_media_type'));
          return;
        }
        final id = await _mediaUpload.uploadLocalFile(
          path: path,
          contentType: mime,
          fileSizeBytes: size,
        );
        mediaIds.add(id);
        if (mediaIds.length >= MediaUploadConstants.maxMediaPerPost) break;
      }
      if (text.isEmpty && mediaIds.isEmpty) {
        emit(state.copyWith(sending: false));
        return;
      }
      final msg = await _repository.sendDirectMessage(
        peerUserId: state.peerUserId,
        body: text.isEmpty ? null : text,
        mediaIds: mediaIds,
      );
      final next = state.messages.any((m) => m.messageId == msg.messageId)
          ? state.messages
          : [...state.messages, msg];
      emit(
        state.copyWith(messages: next, sending: false, pendingMediaPaths: []),
      );
    } on ApiException catch (e) {
      emit(state.copyWith(sending: false, lastError: e.userMessage));
    } catch (e) {
      emit(state.copyWith(sending: false, lastError: e.toString()));
    }
  }

  Future<void> deleteMessage(String messageId) async {
    try {
      await _repository.deleteMessage(messageId);
      emit(
        state.copyWith(
          messages: state.messages
              .where((m) => m.messageId != messageId)
              .toList(),
        ),
      );
    } on ApiException catch (e) {
      emit(state.copyWith(lastError: e.userMessage));
    } catch (e) {
      emit(state.copyWith(lastError: e.toString()));
    }
  }

  Future<bool> blockPeer() async {
    try {
      await _repository.blockUser(state.peerUserId);
      return true;
    } on ApiException catch (e) {
      emit(state.copyWith(lastError: e.userMessage));
      return false;
    } catch (e) {
      emit(state.copyWith(lastError: e.toString()));
      return false;
    }
  }

  void clearError() {
    if (state.lastError != null) {
      emit(state.copyWith(clearError: true));
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    _deletionSubscription?.cancel();
    return super.close();
  }
}
