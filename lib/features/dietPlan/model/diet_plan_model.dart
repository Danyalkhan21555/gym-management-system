import 'package:cloud_firestore/cloud_firestore.dart';

class DietPlanModel {
  final String memberId;
  final String memberName;
  final String trainerId;
  final String trainerName;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;

  const DietPlanModel({
    required this.memberId,
    required this.memberName,
    required this.trainerId,
    required this.trainerName,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DietPlanModel.fromFirestore(Map<String, dynamic> data) {
    return DietPlanModel(
      memberId: data['memberId'] as String? ?? '',
      memberName: data['memberName'] as String? ?? '',
      trainerId: data['trainerId'] as String? ?? '',
      trainerName: data['trainerName'] as String? ?? '',
      content: data['content'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'memberId': memberId,
      'memberName': memberName,
      'trainerId': trainerId,
      'trainerName': trainerName,
      'content': content,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  DietPlanModel copyWith({String? content, DateTime? updatedAt}) {
    return DietPlanModel(
      memberId: memberId,
      memberName: memberName,
      trainerId: trainerId,
      trainerName: trainerName,
      content: content ?? this.content,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isEmpty => content.trim().isEmpty;

  String get preview {
    final trimmed = content.trim();
    if (trimmed.length <= 100) return trimmed;
    return '${trimmed.substring(0, 100)}...';
  }
}
