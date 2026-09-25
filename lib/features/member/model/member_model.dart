import 'package:cloud_firestore/cloud_firestore.dart';

class MemberModel {
  /// Firebase Auth UID — also used as the Firestore document ID
  final String uid;

  /// Human-readable member identifier (e.g. "MEM001")
  final String memberId;

  /// Full display name of the member
  final String name;

  /// Contact phone number
  final String phone;

  /// Contact email address (optional)
  final String email;

  /// Physical residential address (optional)
  final String address;

  /// Member gender: 'male' | 'female' (optional)
  final String gender;

  /// Membership status: 'active' | 'inactive' | 'expired'
  final String status;

  /// Timestamp when the member joined
  final DateTime createdAt;

  /// Profile image URL (optional)
  final String profileImage;

  const MemberModel({
    required this.uid,
    required this.memberId,
    required this.name,
    required this.phone,
    this.email = '',
    this.address = '',
    this.gender = '',
    this.status = 'active',
    required this.createdAt,
    this.profileImage = '',
  });

  factory MemberModel.fromFirestore(Map<String, dynamic> data) {
    return MemberModel(
      uid:          data['uid']          as String? ?? '',
      memberId:     data['memberId']     as String? ?? '',
      name:         data['name']         as String? ?? '',
      phone:        data['phone']        as String? ?? '',
      email:        data['email']        as String? ?? '',
      address:      data['address']      as String? ?? '',
      gender:       data['gender']       as String? ?? '',
      status:       data['status']       as String? ?? 'active',
      createdAt:    (data['createdAt'] as Timestamp?)?.toDate() 
                    ?? DateTime.now(),
      profileImage: data['profileImage'] as String? ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uid':          uid,
      'memberId':     memberId,
      'name':         name,
      'phone':        phone,
      'email':        email,
      'address':      address,
      'gender':       gender,
      'status':       status,
      'createdAt':    Timestamp.fromDate(createdAt),
      'profileImage': profileImage,
    };
  }

  // ── Status helpers ──────────────────────────────────────────────────────────

  bool get isActive   => status == 'active';
  bool get isExpired  => status == 'expired';
  bool get isInactive => status == 'inactive';

  // ── Display helpers ─────────────────────────────────────────────────────────

  String get initial {
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  String get genderLabel {
    switch (gender.toLowerCase()) {
      case 'male':   return 'Male';
      case 'female': return 'Female';
      default:       return gender;
    }
  }

  String get statusLabel {
    switch (status) {
      case 'active':   return 'Active';
      case 'inactive': return 'Inactive';
      case 'expired':  return 'Expired';
      default:         return status;
    }
  }
}
