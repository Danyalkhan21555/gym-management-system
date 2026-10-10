import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../staff/helpers/secondary_auth_helper.dart';
import '../model/member_model.dart';

class MemberRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String _collection = 'members';

  // ── Read methods ────────────────────────────────────────────────────────

  /// Fetches all member documents from Firestore and returns them as a list
  /// of [MemberModel], sorted alphabetically by name (case-insensitive, A–Z).
  /// Returns an empty list if an error occurs.
  Future<List<MemberModel>> getAllMembers() async {
    try {
      final snapshot = await _firestore.collection(_collection).get();
      final members = snapshot.docs
          .map((doc) => MemberModel.fromFirestore(doc.data()))
          .toList();

      // Sort client-side so we don't need a Firestore composite index.
      members.sort(
        (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
      );

      return members;
    } catch (e) {
      debugPrint('Error getting all members: $e');
      return [];
    }
  }

  /// Reads a single member document by its [uid] (= Firestore doc ID).
  /// Returns null if the document does not exist or if an error occurs.
  Future<MemberModel?> getMemberById(String uid) async {
    try {
      final snapshot = await _firestore.collection(_collection).doc(uid).get();

      if (!snapshot.exists) {
        return null;
      }

      return MemberModel.fromFirestore(snapshot.data()!);
    } catch (e) {
      debugPrint('Error getting member by id ($uid): $e');
      return null;
    }
  }

  // ── ID & Email generators ───────────────────────────────────────────────

  /// Generates the next member ID in the format MEM001, MEM002, ...
  /// Based on the current member count.
  Future<String> getNextMemberId() async {
    try {
      final snapshot = await _firestore.collection(_collection).get();
      final count = snapshot.docs.length;
      final nextNumber = count + 1;
      return 'MEM${nextNumber.toString().padLeft(3, '0')}';
    } catch (e) {
      debugPrint('Error generating member ID: $e');
      // Fallback: use timestamp-based ID
      final now = DateTime.now().millisecondsSinceEpoch;
      return 'MEM${now.toString().substring(now.toString().length - 3)}';
    }
  }

  // ── Create member ──────────────────────────────────────────────────────

  /// Creates a new member:
  ///   1. Firebase Auth account (via secondary app so receptionist stays
  ///      logged in)
  ///   2. Firestore member document
  /// Returns the created [MemberModel] on success, null on failure.
  Future<MemberModel?> createMember({
    required String name,
    required String phone,
    required String email,
    required String password,
    required String address,
    required String gender,
    required String plan,
    required int duration,
  }) async {
    try {
      // Step 1: Generate member ID
      final memberId = await getNextMemberId();

      // Step 2: Create Firebase Auth account via secondary app
      final newUid = await SecondaryAuthHelper.createStaffAuthAccount(
        email: email,
        password: password,
      );

      if (newUid == null) {
        debugPrint('Auth account creation failed for $email');
        return null;
      }

      // Step 3: Calculate dates
      final now = DateTime.now();
      final expiryDate = DateTime(now.year, now.month + duration, now.day);

      // Step 4: Build MemberModel
      final member = MemberModel(
        uid: newUid,
        memberId: memberId,
        name: name,
        phone: phone,
        email: email,
        address: address,
        gender: gender,
        status: 'active',
        plan: plan,
        duration: duration,
        startDate: now,
        expiryDate: expiryDate,
        createdAt: now,
      );

      // Step 5: Write to Firestore
      await _firestore
          .collection(_collection)
          .doc(newUid)
          .set(member.toFirestore());

      return member;
    } catch (e) {
      debugPrint('Error creating member: $e');
      return null;
    }
  }

  // ── Update methods ────────────────────────────────────────────────────

  /// Updates only the status field of a member doc.
  /// Returns true on success.
  Future<bool> updateMemberStatus({
    required String uid,
    required String status, // 'active' | 'inactive' | 'expired'
  }) async {
    try {
      await _firestore.collection(_collection).doc(uid).update({
        'status': status,
      });
      return true;
    } catch (e) {
      debugPrint('Error updating member status: $e');
      return false;
    }
  }

  /// Updates the editable fields of a member document.
  /// Only name, phone, address, gender are editable.
  /// Returns true on success.
  Future<bool> updateMember({
    required String uid,
    required String name,
    required String phone,
    required String address,
    required String gender,
  }) async {
    try {
      await _firestore.collection(_collection).doc(uid).update({
        'name': name,
        'phone': phone,
        'address': address,
        'gender': gender,
      });
      return true;
    } catch (e) {
      debugPrint('Error updating member: $e');
      return false;
    }
  }

  /// Renews a membership by updating plan, duration, and dates.
  /// Also sets status back to 'active'.
  Future<bool> renewMembership({
    required String uid,
    required String plan,
    required int duration,
  }) async {
    try {
      final now = DateTime.now();
      final expiryDate = DateTime(now.year, now.month + duration, now.day);

      await _firestore.collection(_collection).doc(uid).update({
        'status': 'active',
        'plan': plan,
        'duration': duration,
        'startDate': Timestamp.fromDate(now),
        'expiryDate': Timestamp.fromDate(expiryDate),
      });
      return true;
    } catch (e) {
      debugPrint('Error renewing membership: $e');
      return false;
    }
  }

  /// Permanently deletes the member Firestore document and any associated
  /// diet plan document (doc ID = member uid).
  /// Does NOT delete the Firebase Auth account (client SDK can't).
  Future<bool> deleteMember(String uid) async {
    try {
      // Delete member doc
      await _firestore.collection(_collection).doc(uid).delete();

      // Delete diet plan if exists
      try {
        await _firestore.collection('diet_plans').doc(uid).delete();
      } catch (e) {
        debugPrint('Failed to delete diet plan for $uid: $e');
      }

      return true;
    } catch (e) {
      debugPrint('Error deleting member: $e');
      return false;
    }
  }
}
