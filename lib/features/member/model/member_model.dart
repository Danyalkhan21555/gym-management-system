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

  /// Contact email address (e.g. "bilawal@gym.com")
  final String email;

  /// Physical residential address (optional)
  final String address;

  /// Member gender: 'male' | 'female' (optional)
  final String gender;

  /// Membership status: 'active' | 'inactive' | 'expired'
  final String status;

  /// Membership plan: 'basic' | 'premium' | 'gold'
  final String plan;

  /// Membership duration in months: 1 | 3 | 6
  final int duration;

  /// When the current membership started
  final DateTime? startDate;

  /// When the current membership expires
  final DateTime? expiryDate;

  /// Timestamp when the member joined the gym
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
    this.plan = 'basic',
    this.duration = 1,
    this.startDate,
    this.expiryDate,
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
      plan:         data['plan']         as String? ?? 'basic',
      duration:     data['duration']     as int?    ?? 1,
      startDate:    (data['startDate'] as Timestamp?)?.toDate(),
      expiryDate:   (data['expiryDate'] as Timestamp?)?.toDate(),
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
      'plan':         plan,
      'duration':     duration,
      'startDate':    startDate != null
                      ? Timestamp.fromDate(startDate!)
                      : null,
      'expiryDate':   expiryDate != null
                      ? Timestamp.fromDate(expiryDate!)
                      : null,
      'createdAt':    Timestamp.fromDate(createdAt),
      'profileImage': profileImage,
    };
  }

  // ── Helper getters ──────────────────────────────────────────────────────

  bool get isActive => status == 'active';
  bool get isExpired => status == 'expired';
  bool get isInactive => status == 'inactive';

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

  String get planLabel {
    switch (plan.toLowerCase()) {
      case 'basic':   return 'Basic';
      case 'premium': return 'Premium';
      case 'gold':    return 'Gold';
      default:        return plan;
    }
  }

  String get durationLabel {
    return duration == 1 ? '1 Month' : '$duration Months';
  }

  /// True if the membership has expired based on expiryDate.
  /// This checks the date directly, regardless of the status field.
  bool get hasExpiredByDate {
    if (expiryDate == null) return false;
    return expiryDate!.isBefore(DateTime.now());
  }

  /// Days remaining until expiry. Negative if already expired.
  /// Returns 0 if expiryDate is null.
  int get daysRemaining {
    if (expiryDate == null) return 0;
    return expiryDate!.difference(DateTime.now()).inDays;
  }

  /// True if the effective status should be 'expired'.
  /// Considers both the status field AND the expiryDate.
  bool get effectiveIsExpired {
    if (status == 'expired') return true;
    if (status == 'active' && hasExpiredByDate) return true;
    return false;
  }
}