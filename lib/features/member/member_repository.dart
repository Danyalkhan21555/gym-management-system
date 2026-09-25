import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:gym_management/features/member/model/member_model.dart';

class MemberRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String _collection = 'members';

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
}
