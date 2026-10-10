import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../memberships/halper/membership_halper.dart';
import '../repository/auth_repository.dart';
import '../repository/profile_repository.dart';
import '../model/auth_user_model.dart';
import '../model/user_profile_model.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;
  final ProfileRepository _profileRepository;

  AuthUserModel? currentUser;
  UserProfileModel? userProfile;

  bool isLoading = false;
  String? errorMessage;

  // ── Splash guard ──
  bool _hasCheckedCurrentUser = false;
  bool get hasCheckedCurrentUser => _hasCheckedCurrentUser;

  // ── Change password state ──
  bool _isChangingPassword = false;
  String? _changePasswordError;
  String? _changePasswordSuccess;

  bool get isChangingPassword => _isChangingPassword;
  String? get changePasswordError => _changePasswordError;
  String? get changePasswordSuccess => _changePasswordSuccess;

  AuthViewModel(this._authRepository, this._profileRepository);

  // ── Login ───────────────────────────────────────────────────────────────

  Future<void> login(String email, String password) async {
    errorMessage = null;
    isLoading = true;
    notifyListeners();

    try {
      currentUser = await _authRepository.signIn(email, password);

      if (currentUser != null) {
        userProfile = await _profileRepository.getUserProfile(
          currentUser!.uid,
        );

        if (userProfile == null) {
          errorMessage = 'User profile not found.';
        } else {
          // Lazy expiry check for members
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

  // ── Logout ──────────────────────────────────────────────────────────────

  Future<void> logout() async {
    await _authRepository.signOut();
    currentUser = null;
    userProfile = null;
    notifyListeners();
  }

  // ── Check current user (session restore) ────────────────────────────────

  Future<void> checkCurrentUser() async {
    currentUser = _authRepository.getCurrentUser();

    if (currentUser != null) {
      userProfile = await _profileRepository.getUserProfile(
        currentUser!.uid,
      );

      _hasCheckedCurrentUser = true;
      notifyListeners();

      // Fire-and-forget: run in background
      if (userProfile != null) {
        _checkMembershipExpiry();
      }
    } else {
      userProfile = null;
      _hasCheckedCurrentUser = true;
      notifyListeners();
    }
  }

  // ── Change password ─────────────────────────────────────────────────────

  /// Attempts to change the current user's password.
  /// Returns true on success.
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    _isChangingPassword = true;
    _changePasswordError = null;
    _changePasswordSuccess = null;
    notifyListeners();

    try {
      await _authRepository.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );

      _changePasswordSuccess = 'Password updated successfully.';
      return true;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'wrong-password':
        case 'invalid-credential':
          _changePasswordError = 'Current password is incorrect.';
          break;
        case 'weak-password':
          _changePasswordError = 'New password is too weak.';
          break;
        case 'requires-recent-login':
          _changePasswordError =
              'Please log out and log in again before changing your password.';
          break;
        case 'network-request-failed':
          _changePasswordError = 'Check your internet connection.';
          break;
        default:
          _changePasswordError = 'Failed to update password. Try again.';
      }
      return false;
    } catch (e) {
      _changePasswordError = 'Something went wrong. Please try again.';
      return false;
    } finally {
      _isChangingPassword = false;
      notifyListeners();
    }
  }

  void clearChangePasswordState() {
    _changePasswordError = null;
    _changePasswordSuccess = null;
    notifyListeners();
  }

  // ── Private: membership expiry check ────────────────────────────────────

  Future<void> _checkMembershipExpiry() async {
    if (userProfile == null) return;
    if (userProfile!.role != 'member') return;

    try {
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
        userProfile = await _profileRepository.getUserProfile(
          currentUser!.uid,
        );
      }
    } catch (e) {
      debugPrint('Error checking membership expiry: $e');
    }
  }
}