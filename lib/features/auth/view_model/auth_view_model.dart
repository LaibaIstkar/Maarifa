import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maarifa/core/providers/auth_providers.dart';
import '../repository/auth_repository.dart';

class AuthViewModel {
  final AuthRepository _authRepository;

  AuthViewModel(this._authRepository);


  bool isUserSignedIn() {
    return _authRepository.getCurrentUser() != null;
  }

  User? getCurrentUser() {
    return _authRepository.getCurrentUser();
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String username,
    required bool isAdmin,
  }) async {
    await _authRepository.signUpWithEmailAndPassword(
      email: email,
      password: password,
      username: username,
      isAdmin: isAdmin,
    );
  }



  Future<void> signIn(String email, String password) async {
    await _authRepository.signInWithEmailAndPassword(email, password);
  }

  Future<void> signOut() async {
    await _authRepository.signOut();
  }

  Future<bool> isAdmin() async {
      return await _authRepository.isAdmin();
  }

  Future<String?> getUsername() async {

    return await _authRepository.getUsername();

  }

  Future<void> resetPassword(String email) async {
    await _authRepository.sendPasswordResetEmail(email);
  }

  Future<void> sendVerificationEmail() async {
    await _authRepository.sendEmailVerification();
  }


  Future<void> deleteUserAccount(String email, String password) async {
    try {
      await _authRepository.reAuthenticateUser(email, password);

      await _authRepository.deleteUserAccount();
    } catch (e) {
      rethrow;
    }
  }

}

final authViewModelProvider = Provider((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return AuthViewModel(authRepository as AuthRepository);
});
