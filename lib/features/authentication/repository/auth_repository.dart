import 'package:firebase_auth/firebase_auth.dart';
import '../model/auth_user_model.dart';

class AuthRepository {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<AuthUserModel?> signIn(String email, String password) async {
    final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    if (userCredential.user != null) {
      return AuthUserModel.fromFirebaseUser(userCredential.user!);
    }
    return null;
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  AuthUserModel? getCurrentUser() {
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      return AuthUserModel.fromFirebaseUser(user);
    }
    return null;
  }

  // ── NEW: Change password ─────────────────────────────────────────────────

  /// Changes the current user's password.
  ///
  /// Requires the current password for re-authentication (Firebase 
  /// mandates a recent login for sensitive operations).
  ///
  /// Throws FirebaseAuthException on failure with codes:
  ///   - 'wrong-password'       → current password is incorrect
  ///   - 'weak-password'        → new password too short
  ///   - 'requires-recent-login' → session too old (rare after re-auth)
  ///   - 'network-request-failed'
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'no-current-user',
        message: 'No user is currently signed in.',
      );
    }

    final email = user.email;
    if (email == null) {
      throw FirebaseAuthException(
        code: 'no-email',
        message: 'User has no email address.',
      );
    }

    // ── 1. Re-authenticate with current password ──
    final credential = EmailAuthProvider.credential(
      email: email,
      password: currentPassword,
    );
    await user.reauthenticateWithCredential(credential);

    // ── 2. Update to the new password ──
    await user.updatePassword(newPassword);
  }
}