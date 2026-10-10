import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../model/user_profile_model.dart';

class ProfileRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Fetches the profile for the given [uid] from either the staff
  /// or members collection.
  ///
  /// Uses direct doc reads (doc ID = uid) instead of queries, because
  /// Firestore Security Rules with `docId == request.auth.uid` only
  /// allow direct reads, not queries.
  Future<UserProfileModel?> getUserProfile(String uid) async {
    try {
      // ── 1. Try staff collection (doc ID = uid) ──
      final staffDoc = await _firestore.collection('staff').doc(uid).get();

      if (staffDoc.exists) {
        final data = staffDoc.data()!;
        return UserProfileModel.fromFirestore(data);
      }

      // ── 2. Try members collection (doc ID = uid) ──
      final memberDoc = await _firestore.collection('members').doc(uid).get();

      if (memberDoc.exists) {
        final data = memberDoc.data()!;

        // Member docs don't have a `role` field.
        // Inject `role: 'member'` so UserProfileModel and AuthGate
        // can route correctly.
        final dataWithRole = Map<String, dynamic>.from(data);
        if ((dataWithRole['role'] as String?)?.isEmpty ?? true) {
          dataWithRole['role'] = 'member';
        }

        return UserProfileModel.fromFirestore(dataWithRole);
      }

      // ── 3. Not found ──
      return null;
    } catch (e) {
      debugPrint('Error getting user profile: $e');
      return null;
    }
  }
}
