import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../model/conversation_model.dart';
import '../model/message_model.dart';

class ChatRepository {
  final FirebaseFirestore _firestore;

  ChatRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  static const String _conversationsCollection = 'conversations';
  static const String _messagesSubcollection = 'messages';

  /// Watches all messages in real time for a given room, ordered chronologically.
  Stream<List<MessageModel>> watchMessages(String roomId) {
    return _firestore
        .collection(_conversationsCollection)
        .doc(roomId)
        .collection(_messagesSubcollection)
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => MessageModel.fromFirestore(
                  doc.data(),
                  id: doc.id,
                ),
              )
              .toList(),
        );
  }

  /// Sends a message into the conversation subcollection and updates the
  /// parent conversation's last message metadata atomically via a batch write.
  Future<bool> sendMessage({
    required String roomId,
    required String senderId,
    required String senderName,
    required String text,
  }) async {
    try {
      final batch = _firestore.batch();
      final now = DateTime.now();
      final convDocRef =
          _firestore.collection(_conversationsCollection).doc(roomId);
      final msgDocRef =
          convDocRef.collection(_messagesSubcollection).doc();

      final trimmedText = text.trim();
      final previewText = trimmedText.length > 100
          ? trimmedText.substring(0, 100)
          : trimmedText;

      final message = MessageModel(
        id: msgDocRef.id,
        senderId: senderId,
        senderName: senderName,
        text: trimmedText,
        timestamp: now,
      );

      // 1. Add new message document
      batch.set(msgDocRef, message.toFirestore());

      // 2. Update conversation summary doc
      batch.update(convDocRef, {
        'lastMessage': previewText,
        'lastMessageAt': Timestamp.fromDate(now),
        'lastMessageSenderId': senderId,
        'updatedAt': Timestamp.fromDate(now),
      });

      await batch.commit();
      return true;
    } catch (e) {
      debugPrint('Error sending message in room $roomId: $e');
      return false;
    }
  }

  /// Gets an existing conversation room or creates a new one deterministically.
  Future<ConversationModel?> getOrCreateConversation({
    required String user1Id,
    required String user1Name,
    required String user1Role,
    required String user2Id,
    required String user2Name,
    required String user2Role,
  }) async {
    try {
      final roomId = ConversationModel.generateRoomId(user1Id, user2Id);
      final docRef =
          _firestore.collection(_conversationsCollection).doc(roomId);
      final snapshot = await docRef.get();

      if (snapshot.exists && snapshot.data() != null) {
        return ConversationModel.fromFirestore(
          snapshot.data()!,
          roomId: snapshot.id,
        );
      }

      final now = DateTime.now();
      final sortedIds = [user1Id, user2Id]..sort();

      final newConversation = ConversationModel(
        roomId: roomId,
        participantIds: sortedIds,
        participantNames: {
          user1Id: user1Name,
          user2Id: user2Name,
        },
        participantRoles: {
          user1Id: user1Role,
          user2Id: user2Role,
        },
        lastMessage: '',
        lastMessageAt: null,
        lastMessageSenderId: '',
        createdAt: now,
        updatedAt: now,
      );

      await docRef.set(newConversation.toFirestore());
      return newConversation;
    } catch (e) {
      debugPrint('Error in getOrCreateConversation: $e');
      return null;
    }
  }

  /// Reads a single conversation document by room ID.
  Future<ConversationModel?> getConversation(String roomId) async {
    try {
      final snapshot = await _firestore
          .collection(_conversationsCollection)
          .doc(roomId)
          .get();

      if (!snapshot.exists || snapshot.data() == null) {
        return null;
      }

      return ConversationModel.fromFirestore(
        snapshot.data()!,
        roomId: snapshot.id,
      );
    } catch (e) {
      debugPrint('Error getting conversation $roomId: $e');
      return null;
    }
  }

  /// Watches a conversation summary document in real time.
  Stream<ConversationModel?> watchConversation(String roomId) {
    return _firestore
        .collection(_conversationsCollection)
        .doc(roomId)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) {
        return null;
      }
      return ConversationModel.fromFirestore(
        snapshot.data()!,
        roomId: snapshot.id,
      );
    });
  }
}
