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
}
