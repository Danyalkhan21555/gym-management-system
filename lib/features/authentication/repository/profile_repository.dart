import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/user_profile_model.dart';

class ProfileRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<UserProfileModel?> getUserProfile(String uid) async {
    print('DEBUG: getUserProfile called with UID: $uid');
    try {
      // First search the staff collection
      final staffQuery = await _firestore
          .collection('staff')
          .where('uid', isEqualTo: uid)
          .limit(1)
          .get();

      print('DEBUG: staffQuery.docs.isEmpty: ${staffQuery.docs.isEmpty}');

      if (staffQuery.docs.isNotEmpty) {
        final data = staffQuery.docs.first.data();
        print('DEBUG: staff document found. Data: $data');
        return UserProfileModel.fromFirestore(
          data,
        );
      }

      print('DEBUG: staff is empty, searching members');

      // If no staff document is found, search the members collection
      final membersQuery = await _firestore
          .collection('members')
          .where('uid', isEqualTo: uid)
          .limit(1)
          .get();

      if (membersQuery.docs.isNotEmpty) {
        final data = membersQuery.docs.first.data();
        print('DEBUG: members document found. Data: $data');
        return UserProfileModel.fromFirestore(
          data,
        );
      }

      // If neither staff nor member is found
      print('DEBUG: neither staff nor member found');
      return null;
    } catch (e) {
      print('DEBUG: Caught exception in getUserProfile: $e');
      print('Error fetching user profile: $e');
      return null;
    }
  }
}