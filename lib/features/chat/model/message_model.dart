import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  /// Firestore document ID (may be empty for newly instantiated messages)
  final String id;

  /// UID of the user who sent the message
  final String senderId;

  /// Display name of the sender
  final String senderName;

  /// Message body text
  final String text;

  /// Timestamp when the message was sent
  final DateTime timestamp;

  const MessageModel({
    this.id = '',
    required this.senderId,
    required this.senderName,
    required this.text,
    required this.timestamp,
  });

  factory MessageModel.fromFirestore(
    Map<String, dynamic> data, {
    String id = '',
  }) {
    return MessageModel(
      id: id.isNotEmpty ? id : (data['id'] as String? ?? ''),
      senderId: data['senderId'] as String? ?? '',
      senderName: data['senderName'] as String? ?? '',
      text: data['text'] as String? ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'senderId': senderId,
      'senderName': senderName,
      'text': text,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }

  MessageModel copyWith({
    String? id,
    String? senderId,
    String? senderName,
    String? text,
    DateTime? timestamp,
  }) {
    return MessageModel(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      text: text ?? this.text,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  /// True if the message body contains only whitespace or is empty.
  bool get isEmpty => text.trim().isEmpty;
}
