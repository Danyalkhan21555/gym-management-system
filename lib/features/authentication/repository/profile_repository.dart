import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/user_profile_model.dart';
import 'package:flutter/foundation.dart';

class ProfileRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<UserProfileModel?> getUserProfile(String uid) async {
    debugPrint('DEBUG: getUserProfile called with UID: $uid');
    try {
      // First search the staff collection
      final staffQuery = await _firestore
          .collection('staff')
          .where('uid', isEqualTo: uid)
          .limit(1)
          .get();

      debugPrint('DEBUG: staffQuery.docs.isEmpty: ${staffQuery.docs.isEmpty}');

      if (staffQuery.docs.isNotEmpty) {
        final data = staffQuery.docs.first.data();
        debugPrint('DEBUG: staff document found. Data: $data');
        return UserProfileModel.fromFirestore(data);
      }

      debugPrint('DEBUG: staff is empty, searching members');

      // If no staff document is found, search the members collection
      final membersQuery = await _firestore
          .collection('members')
          .where('uid', isEqualTo: uid)
          .limit(1)
          .get();

      if (membersQuery.docs.isNotEmpty) {
        final data = membersQuery.docs.first.data();
        debugPrint('DEBUG: members document found. Data: $data');
        return UserProfileModel.fromFirestore(data);
      }

      // If neither staff nor member is found
      debugPrint('DEBUG: neither staff nor member found');
      return null;
    } catch (e) {
      debugPrint('DEBUG: Caught exception in getUserProfile: $e');
      debugPrint('Error fetching user profile: $e');
      return null;
    }
  }
}
