import 'package:cloud_firestore/cloud_firestore.dart';

class ConversationModel {
  /// Unique room ID (also used as the Firestore document ID)
  final String roomId;

  /// List of participant UIDs (sorted)
  final List<String> participantIds;

  /// Map of participant UID to display name
  final Map<String, String> participantNames;

  /// Map of participant UID to role ('trainer' | 'member' | etc.)
  final Map<String, String> participantRoles;

  /// Preview of the last message sent
  final String lastMessage;

  /// Timestamp of the last message sent (nullable if conversation is brand new)
  final DateTime? lastMessageAt;

  /// UID of the user who sent the last message
  final String lastMessageSenderId;

  /// Timestamp when the conversation room was created
  final DateTime createdAt;

  /// Timestamp when the conversation room was last updated
  final DateTime updatedAt;

  const ConversationModel({
    required this.roomId,
    required this.participantIds,
    required this.participantNames,
    required this.participantRoles,
    required this.lastMessage,
    this.lastMessageAt,
    required this.lastMessageSenderId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ConversationModel.fromFirestore(
    Map<String, dynamic> data, {
    required String roomId,
  }) {
    return ConversationModel(
      roomId: roomId,
      participantIds: List<String>.from(data['participantIds'] as List? ?? []),
      participantNames: Map<String, String>.from(
        (data['participantNames'] as Map?)?.map(
              (key, value) => MapEntry(key.toString(), value.toString()),
            ) ??
            {},
      ),
      participantRoles: Map<String, String>.from(
        (data['participantRoles'] as Map?)?.map(
              (key, value) => MapEntry(key.toString(), value.toString()),
            ) ??
            {},
      ),
      lastMessage: data['lastMessage'] as String? ?? '',
      lastMessageAt: (data['lastMessageAt'] as Timestamp?)?.toDate(),
      lastMessageSenderId: data['lastMessageSenderId'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'participantIds': participantIds,
      'participantNames': participantNames,
      'participantRoles': participantRoles,
      'lastMessage': lastMessage,
      'lastMessageAt':
          lastMessageAt != null ? Timestamp.fromDate(lastMessageAt!) : null,
      'lastMessageSenderId': lastMessageSenderId,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  ConversationModel copyWith({
    String? roomId,
    List<String>? participantIds,
    Map<String, String>? participantNames,
    Map<String, String>? participantRoles,
    String? lastMessage,
    DateTime? lastMessageAt,
    String? lastMessageSenderId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ConversationModel(
      roomId: roomId ?? this.roomId,
      participantIds: participantIds ?? this.participantIds,
      participantNames: participantNames ?? this.participantNames,
      participantRoles: participantRoles ?? this.participantRoles,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      lastMessageSenderId: lastMessageSenderId ?? this.lastMessageSenderId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // ── Helper getters ──────────────────────────────────────────────────────────

  /// Returns the OTHER participant's UID (not the current user).
  String otherParticipantId(String currentUserId) {
    return participantIds.firstWhere(
      (id) => id != currentUserId,
      orElse: () => '',
    );
  }

  /// Returns the OTHER participant's display name.
  String otherParticipantName(String currentUserId) {
    final otherId = otherParticipantId(currentUserId);
    return participantNames[otherId] ?? 'Unknown';
  }

  /// Returns the OTHER participant's role (trainer/member).
  String otherParticipantRole(String currentUserId) {
    final otherId = otherParticipantId(currentUserId);
    return participantRoles[otherId] ?? '';
  }

  /// Static helper: generate a deterministic room ID from two UIDs.
  static String generateRoomId(String uid1, String uid2) {
    final ids = [uid1, uid2]..sort();
    return ids.join('_');
  }
}
