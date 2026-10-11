import 'package:firebase_auth/firebase_auth.dart';

abstract interface class AdminAuthService {
  String? get currentEmail;
  Future<bool> get hasAdminAccess;
  Future<void> signIn(String email, String password);
  Future<void> signOut();
  Future<void> sendEmailChangeVerification({
    required String currentPassword,
    required String newEmail,
  });
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });
}

class FirebaseAdminAuthService implements AdminAuthService {
  FirebaseAdminAuthService(this._auth);

  final FirebaseAuth _auth;

  @override
  String? get currentEmail => _auth.currentUser?.email;

  @override
  Future<bool> get hasAdminAccess async {
    final user = _auth.currentUser;
    if (user == null) return false;
    final token = await user.getIdTokenResult(true);
    if (token.claims?['admin'] == true) return true;
    await _auth.signOut();
    return false;
  }

  @override
  Future<void> signIn(String email, String password) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final user = credential.user;
    if (user == null) {
      throw StateError('Firebase did not return an administrator user.');
    }
    final token = await user.getIdTokenResult(true);
    if (token.claims?['admin'] != true) {
      await _auth.signOut();
      throw StateError(
        'This account is not authorized for the admin workspace.',
      );
    }
  }

  @override
  Future<void> signOut() => _auth.signOut();

  Future<User> _reauthenticate(String currentPassword) async {
    final user = _auth.currentUser;
    final email = user?.email;
    if (user == null || email == null || email.isEmpty) {
      throw StateError('Sign in again with an administrator email account.');
    }
    final token = await user.getIdTokenResult(true);
    if (token.claims?['admin'] != true) {
      await _auth.signOut();
      throw StateError('This account is not authorized for admin settings.');
    }
    await user.reauthenticateWithCredential(
      EmailAuthProvider.credential(email: email, password: currentPassword),
    );
    return user;
  }

  @override
  Future<void> sendEmailChangeVerification({
    required String currentPassword,
    required String newEmail,
  }) async {
    final user = await _reauthenticate(currentPassword);
    await user.verifyBeforeUpdateEmail(newEmail.trim());
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = await _reauthenticate(currentPassword);
    await user.updatePassword(newPassword);
  }
}
