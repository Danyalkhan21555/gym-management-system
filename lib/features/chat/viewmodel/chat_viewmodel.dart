import 'dart:async';
import 'package:flutter/foundation.dart';

import '../model/message_model.dart';
import '../repository/chat_repository.dart';

class ChatViewModel extends ChangeNotifier {
  final ChatRepository _repository;

  List<MessageModel> _messages = [];
  bool _isLoadingMessages = false;
  bool _isSending = false;
  bool _isClearing = false;
  String? _errorMessage;
  StreamSubscription<List<MessageModel>>? _messagesSubscription;

  ChatViewModel(this._repository);

  // ── Getters ─────────────────────────────────────────────────────────────────

  List<MessageModel> get messages => _messages;
  bool get isLoadingMessages => _isLoadingMessages;
  bool get isSending => _isSending;
  bool get isClearing => _isClearing;
  String? get errorMessage => _errorMessage;

  // ── Methods ──────────────────────────────────────────────────────────────────

  /// Starts listening to real-time messages for the given conversation room.
  void startWatchingMessages(String roomId) {
    _messagesSubscription?.cancel();

    _isLoadingMessages = true;
    _errorMessage = null;
    notifyListeners();

    _messagesSubscription = _repository.watchMessages(roomId).listen(
      (data) {
        _messages = data;
        _isLoadingMessages = false;
        _errorMessage = null;
        notifyListeners();
      },
      onError: (error) {
        debugPrint('Error in watchMessages stream: $error');
        _errorMessage = 'Failed to load messages.';
        _isLoadingMessages = false;
        notifyListeners();
      },
    );
  }

  /// Sends a new message in the specified room.
  Future<bool> sendMessage({
    required String roomId,
    required String senderId,
    required String senderName,
    required String text,
  }) async {
    if (text.trim().isEmpty) {
      return false;
    }

    _isSending = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await _repository.sendMessage(
        roomId: roomId,
        senderId: senderId,
        senderName: senderName,
        text: text,
      );

      if (!success) {
        _errorMessage = 'Failed to send message.';
      }

      return success;
    } catch (e) {
      debugPrint('Error sending message: $e');
      _errorMessage = 'Failed to send message.';
      return false;
    } finally {
      _isSending = false;
      notifyListeners();
    }
  }

  /// Stops listening to the current conversation room and clears message state.
  void stopWatchingMessages() {
    _messagesSubscription?.cancel();
    _messagesSubscription = null;
    _messages = [];
    notifyListeners();
  }

  /// Clears any active error message.
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Deletes the entire conversation and all messages.
  Future<bool> clearChat(String roomId) async {
    _isClearing = true;
    notifyListeners();

    try {
      final success = await _repository.deleteConversation(roomId);
      if (success) {
        // Clear local message list
        _messages = [];
      }
      return success;
    } catch (e) {
      return false;
    } finally {
      _isClearing = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _messagesSubscription?.cancel();
    super.dispose();
  }
}
