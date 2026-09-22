import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/announcement_model.dart';

class AnnouncementRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String _collection = 'announcements';
  static const String _docId = 'current';

  /// Reads the current announcement from Firestore.
  /// Returns null if the document does not exist or if an error occurs.
  Future<AnnouncementModel?> getAnnouncement() async {
    try {
      final snapshot = await _firestore.collection(_collection).doc(_docId).get();
      if (!snapshot.exists) {
        return null;
      }
      return AnnouncementModel.fromFirestore(snapshot.data()!);
    } catch (e) {
      // ignore: avoid_print
      print('Error getting announcement: $e');
      return null;
    }
  }

  /// Saves the announcement to Firestore.
  /// Fully overwrites the existing document so updatedAt is fresh.
  Future<void> saveAnnouncement(AnnouncementModel announcement) async {
    await _firestore
        .collection(_collection)
        .doc(_docId)
        .set(announcement.toFirestore());
  }

  /// Deletes the current announcement from Firestore.
  Future<void> deleteAnnouncement() async {
    await _firestore.collection(_collection).doc(_docId).delete();
  }
}
