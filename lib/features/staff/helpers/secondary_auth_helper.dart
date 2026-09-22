import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../../../firebase_options.dart';

/// A helper that creates Firebase Auth accounts for new staff members
/// without signing out the currently logged-in admin.
///
/// It achieves this by initialising (or reusing) a secondary Firebase app
/// instance named [_secondaryAppName] and performing all auth operations
/// against that instance instead of the default one.
class SecondaryAuthHelper {
  static const String _secondaryAppName = 'staff_creator';

  /// Creates a Firebase Authentication account for a staff member.
  ///
  /// Returns the new user's UID on success, or `null` if any error occurs.
  /// The admin's current session is unaffected because this method operates
  /// on a secondary [FirebaseApp] instance.
  static Future<String?> createStaffAuthAccount({
    required String email,
    required String password,
  }) async {
    try {
      // Reuse the secondary app if it was already initialised; otherwise
      // spin up a new one with the same Firebase project options.
      final FirebaseApp app = Firebase.apps.firstWhere(
        (a) => a.name == _secondaryAppName,
        orElse: () => throw StateError('not_found'),
      );

      return await _doCreateUser(app, email, password);
    } on StateError {
      // Secondary app does not exist yet — initialise it.
      try {
        final FirebaseApp app = await Firebase.initializeApp(
          name: _secondaryAppName,
          options: DefaultFirebaseOptions.currentPlatform,
        );
        return await _doCreateUser(app, email, password);
      } catch (e) {
        debugPrint('[SecondaryAuthHelper] Failed to initialise secondary app: $e');
        return null;
      }
    } catch (e) {
      debugPrint('[SecondaryAuthHelper] createStaffAuthAccount error: $e');
      return null;
    }
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  /// Uses [app]'s [FirebaseAuth] instance to create a new user, captures the
  /// UID, signs out immediately, and returns the UID.
  static Future<String?> _doCreateUser(
    FirebaseApp app,
    String email,
    String password,
  ) async {
    final FirebaseAuth secondaryAuth = FirebaseAuth.instanceFor(app: app);

    try {
      final UserCredential credential =
          await secondaryAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final String? uid = credential.user?.uid;

      // Sign out from the secondary app immediately so it holds no session.
      await secondaryAuth.signOut();

      return uid;
    } catch (e) {
      debugPrint('[SecondaryAuthHelper] _doCreateUser error: $e');
      // Attempt a best-effort sign-out even on failure.
      try {
        await secondaryAuth.signOut();
      } catch (_) {}
      return null;
    }
  }
}
