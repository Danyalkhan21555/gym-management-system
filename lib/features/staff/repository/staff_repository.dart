import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../helpers/secondary_auth_helper.dart';
import '../model/staff_model.dart';

class StaffRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String _collection = 'staff';

  /// Fetches all staff documents from Firestore and returns them as a list
  /// of [StaffModel], sorted alphabetically by name (case-insensitive, A–Z).
  /// Returns an empty list if an error occurs.
  Future<List<StaffModel>> getAllStaff() async {
    try {
      final snapshot = await _firestore.collection(_collection).get();
      final staff = snapshot.docs
          .map((doc) => StaffModel.fromFirestore(doc.data()))
          .toList();

      // Sort client-side so we don't need a Firestore composite index.
      staff.sort(
        (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
      );

      return staff;
    } catch (e) {
      // ignore: avoid_print
      print('Error getting all staff: $e');
      return [];
    }
  }

  /// Reads a single staff document by its [uid] (= Firestore doc ID).
  /// Returns null if the document does not exist or if an error occurs.
  Future<StaffModel?> getStaffById(String uid) async {
    try {
      final snapshot =
          await _firestore.collection(_collection).doc(uid).get();
      if (!snapshot.exists) {
        return null;
      }
      return StaffModel.fromFirestore(snapshot.data()!);
    } catch (e) {
      // ignore: avoid_print
      print('Error getting staff by id ($uid): $e');
      return null;
    }
  }

  /// Creates a new staff Auth account and Firestore document.
  /// Returns the created [StaffModel] on success, or null on failure.
  Future<StaffModel?> createStaff({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String role,
  }) async {
    try {
      // Step 1 — Generate profileId from current staff count.
      int count;
      try {
        final countSnap =
            await _firestore.collection(_collection).count().get();
        count = countSnap.count ?? 0;
      } catch (_) {
        // Fallback: fetch all docs and count locally.
        final snap = await _firestore.collection(_collection).get();
        count = snap.docs.length;
      }
      final profileId = 'STF${(count + 1).toString().padLeft(3, '0')}';

      // Step 2 — Create Firebase Auth account via secondary helper.
      final newUid = await SecondaryAuthHelper.createStaffAuthAccount(
        email: email,
        password: password,
      );
      if (newUid == null) {
        debugPrint('createStaff: Auth account creation returned null.');
        return null;
      }

      // Step 3 — Build the model.
      final model = StaffModel(
        uid: newUid,
        profileId: profileId,
        name: name,
        role: role,
        status: 'active',
        phone: phone,
        email: email,
      );

      // Step 4 — Write to Firestore.
      try {
        await _firestore
            .collection(_collection)
            .doc(newUid)
            .set(model.toFirestore());
      } catch (e) {
        debugPrint('createStaff: Firestore write failed: $e');
        return null;
      }

      // Step 5 — Return the created model.
      return model;
    } catch (e) {
      debugPrint('createStaff: Unexpected error: $e');
      return null;
    }
  }

  /// Updates the status of a staff member ('active' | 'inactive') in Firestore.
  Future<bool> updateStaffStatus({
    required String uid,
    required String status,
  }) async {
    try {
      await _firestore.collection(_collection).doc(uid).update({
        'status': status,
      });
      return true;
    } catch (e) {
      debugPrint('Error updating staff status: $e');
      return false;
    }
  }
}
