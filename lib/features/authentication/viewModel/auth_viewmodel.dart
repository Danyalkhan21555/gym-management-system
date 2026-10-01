import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../repository/auth_repository.dart';
import '../repository/profile_repository.dart';
import '../model/auth_user_model.dart';
import '../model/user_profile_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../memberships/halper/membership_halper.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;
  final ProfileRepository _profileRepository;

  AuthUserModel? currentUser;
  UserProfileModel? userProfile;

  bool isLoading = false;
  String? errorMessage;

  AuthViewModel(this._authRepository, this._profileRepository);

  Future<void> login(String email, String password) async {
    errorMessage = null;
    isLoading = true;
    notifyListeners();

    try {
      currentUser = await _authRepository.signIn(email, password);

      if (currentUser != null) {
        userProfile = await _profileRepository.getUserProfile(currentUser!.uid);

        if (userProfile == null) {
          errorMessage = 'User profile not found.';
        } else {
          // ── Lazy expiry check for members ──
          await _checkMembershipExpiry();
        }
      }
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'invalid-credential':
        case 'wrong-password':
        case 'user-not-found':
          errorMessage = 'Invalid email or password.';
          break;

        case 'invalid-email':
          errorMessage = 'Please enter a valid email address.';
          break;

        case 'too-many-requests':
          errorMessage = 'Too many login attempts. Please try again later.';
          break;

        case 'network-request-failed':
          errorMessage = 'Please check your internet connection.';
          break;

        default:
          errorMessage = 'Login failed. Please try again.';
      }
    } catch (e) {
      errorMessage = 'Something went wrong. Please try again.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _authRepository.signOut();

    currentUser = null;
    userProfile = null;

    notifyListeners();
  }

  Future<void> checkCurrentUser() async {
    currentUser = _authRepository.getCurrentUser();

    if (currentUser != null) {
      userProfile = await _profileRepository.getUserProfile(currentUser!.uid);

      // ── Lazy expiry check for members ──
      if (userProfile != null) {
        await _checkMembershipExpiry();
      }
    } else {
      userProfile = null;
    }

    notifyListeners();
  }

  // ── Private helpers ──────────────────────────────────────────────────────

  /// If the current user is a member, checks their membership expiry
  /// and updates Firestore if needed. Refreshes userProfile afterwards.
  Future<void> _checkMembershipExpiry() async {
    if (userProfile == null) return;
    if (userProfile!.role != 'member') return;

    try {
      // Fetch the member doc to get expiryDate and current status
      final memberDoc = await FirebaseFirestore.instance
          .collection('members')
          .doc(userProfile!.uid)
          .get();

      if (!memberDoc.exists) return;

      final data = memberDoc.data();
      if (data == null) return;

      final expiryDate = (data['expiryDate'] as Timestamp?)?.toDate();
      final currentStatus = data['status'] as String? ?? 'active';

      final wasUpdated = await MembershipHelper.checkAndUpdateExpiry(
        memberUid: userProfile!.uid,
        expiryDate: expiryDate,
        currentStatus: currentStatus,
      );

      if (wasUpdated) {
        // Refresh profile so UI reflects the new status
        userProfile = await _profileRepository.getUserProfile(currentUser!.uid);
      }
    } catch (e) {
      debugPrint('Error checking membership expiry: $e');
      // Silent fail — do not block login
    }
  }
}
