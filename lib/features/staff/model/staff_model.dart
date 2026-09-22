class StaffModel {
  /// Firebase Auth UID — also used as the Firestore document ID
  final String uid;

  /// Human-readable staff identifier (e.g. "STF001")
  final String profileId;

  /// Full display name of the staff member
  final String name;

  /// Role within the gym: "admin" | "receptionist" | "trainer"
  final String role;

  /// Account status: "active" | "inactive"
  final String status;

  /// Contact phone number (optional, may be empty)
  final String phone;

  /// Contact email address (optional, may be empty)
  final String email;

  const StaffModel({
    required this.uid,
    required this.profileId,
    required this.name,
    required this.role,
    required this.status,
    this.phone = '',
    this.email = '',
  });

  factory StaffModel.fromFirestore(Map<String, dynamic> data) {
    return StaffModel(
      uid:       data['uid']       as String? ?? '',
      profileId: data['profileId'] as String? ?? '',
      name:      data['name']      as String? ?? '',
      role:      data['role']      as String? ?? '',
      status:    data['status']    as String? ?? 'active',
      phone:     data['phone']     as String? ?? '',
      email:     data['email']     as String? ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uid':       uid,
      'profileId': profileId,
      'name':      name,
      'role':      role,
      'status':    status,
      'phone':     phone,
      'email':     email,
    };
  }

  // ── Status helpers ──────────────────────────────────────────────────────────

  /// Returns true when the staff account is active.
  bool get isActive => status == 'active';

  // ── Role helpers ────────────────────────────────────────────────────────────

  bool get isAdmin        => role == 'admin';
  bool get isReceptionist => role == 'receptionist';
  bool get isTrainer      => role == 'trainer';

  /// Human-readable role label for display in the UI.
  String get roleLabel {
    switch (role) {
      case 'admin':        return 'Admin';
      case 'receptionist': return 'Receptionist';
      case 'trainer':      return 'Trainer';
      default:             return role;
    }
  }
}
