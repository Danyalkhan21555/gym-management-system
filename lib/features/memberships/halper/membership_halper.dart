import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Helper for membership-related operations, especially expiry handling.
///
/// The app uses a **lazy expiry check** approach: instead of running a
/// daily server job, we check for expiry whenever a member is accessed
/// (login, app open, dashboard load). If a member's `expiryDate` has
/// passed but the Firestore `status` still says 'active', we update it
/// to 'expired'.
class MembershipHelper {
  static const String _membersCollection = 'members';

  /// Returns true if [expiryDate] is before now.
  /// Pure function — no Firestore calls.
  static bool isExpiredByDate(DateTime? expiryDate) {
    if (expiryDate == null) return false;
    return expiryDate.isBefore(DateTime.now());
  }

  /// Checks a member's expiry status and updates Firestore if needed.
  ///
  /// [memberUid]      — Firestore doc ID of the member.
  /// [expiryDate]     — the member's current expiry date.
  /// [currentStatus]  — the member's current status field.
  ///
  /// If the member is currently 'active' but the expiry date has passed,
  /// this updates the Firestore doc's status to 'expired'.
  ///
  /// Does NOT update if:
  ///   - status is already 'expired' or 'inactive'
  ///   - expiryDate is null
  ///   - expiryDate is in the future
  ///
  /// Returns true if an update was performed, false otherwise.
  static Future<bool> checkAndUpdateExpiry({
    required String memberUid,
    required DateTime? expiryDate,
    required String currentStatus,
  }) async {
    // Skip if not active
    if (currentStatus != 'active') return false;

    // Skip if no expiry date
    if (expiryDate == null) return false;

    // Skip if not expired yet
    if (!isExpiredByDate(expiryDate)) return false;

    // Update Firestore
    try {
      await FirebaseFirestore.instance
          .collection(_membersCollection)
          .doc(memberUid)
          .update({'status': 'expired'});
      debugPrint('Membership marked expired for $memberUid');
      return true;
    } catch (e) {
      debugPrint('Error updating membership status: $e');
      return false;
    }
  }
}
