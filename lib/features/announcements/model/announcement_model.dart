import 'package:cloud_firestore/cloud_firestore.dart';

class AnnouncementModel {
  /// The paragraph written by the admin
  final String content;

  /// Timestamp when the announcement was last updated
  final DateTime updatedAt;

  /// Firebase UID of the admin who updated it
  final String updatedBy;

  /// Display name of the admin (e.g. "Admin")
  final String updatedByName;

  const AnnouncementModel({
    required this.content,
    required this.updatedAt,
    required this.updatedBy,
    required this.updatedByName,
  });

  factory AnnouncementModel.fromFirestore(Map<String, dynamic> data) {
    return AnnouncementModel(
      content: data['content'] as String? ?? '',
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedBy: data['updatedBy'] as String? ?? '',
      updatedByName: data['updatedByName'] as String? ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'content': content,
      'updatedAt': Timestamp.fromDate(updatedAt),
      'updatedBy': updatedBy,
      'updatedByName': updatedByName,
    };
  }
}
