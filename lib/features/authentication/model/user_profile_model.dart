class UserProfileModel {
  final String uid;
  final String profileId;
  final String name;
  final String role;
  final String status;

  const UserProfileModel({
    required this.uid,
    required this.profileId,
    required this.name,
    required this.role,
    required this.status,
  });

  factory UserProfileModel.fromFirestore(Map<String, dynamic> data) {
    return UserProfileModel(
      uid: data['uid'] as String? ?? '',
      profileId: data['profileId'] as String? ?? '',
      name: data['name'] as String? ?? '',
      role: data['role'] as String? ?? '',
      status: data['status'] as String? ?? '',
    );
  }
}
