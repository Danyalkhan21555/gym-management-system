import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../model/dashboard_stats_model.dart';

class DashboardStatsRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Fetches member and staff collections from Firestore to compute dashboard statistics.
  Future<DashboardStatsModel> getStats() async {
    try {
      // Fetch all members and staff (client-side count)
      final membersSnap = await _firestore.collection('members').get();
      final staffSnap = await _firestore.collection('staff').get();

      final members = membersSnap.docs.map((d) => d.data()).toList();

      // Total members count
      final totalMembers = members.length;

      // Active members count
      final activeMembers = members.where(
        (m) => m['status'] == 'active',
      ).length;

      // Total staff count
      final totalStaff = staffSnap.docs.length;

      // New members added in current calendar month
      final now = DateTime.now();
      final newMembersThisMonth = members.where((m) {
        final createdAt = m['createdAt'];
        if (createdAt == null) return false;
        final dt = (createdAt as Timestamp).toDate();
        return dt.year == now.year && dt.month == now.month;
      }).length;

      return DashboardStatsModel(
        totalMembers: totalMembers,
        activeMembers: activeMembers,
        totalStaff: totalStaff,
        newMembersThisMonth: newMembersThisMonth,
      );
    } catch (e) {
      debugPrint('Error fetching dashboard stats: $e');
      return DashboardStatsModel.empty();
    }
  }
}
