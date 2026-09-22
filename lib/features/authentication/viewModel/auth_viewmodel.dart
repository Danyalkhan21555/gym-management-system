import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
    } else {
      userProfile = null;
    }

    notifyListeners();
  }
}
