

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;


  AuthRepository(this._firebaseAuth, this._firestore);

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  User? getCurrentUser() {
    return _firebaseAuth.currentUser;
  }

  Future<User?> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String username,
    required bool isAdmin,
  }) async {
    final QuerySnapshot result = await _firestore.collection('users')
        .where('username', isEqualTo: username).get();

    if (result.docs.isNotEmpty) {
      throw Exception('Username is already taken');
    }

    UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    User? user = userCredential.user;

    if (user != null) {
      // Retrieve the FCM token
      String? fcmToken = await _firebaseMessaging.getToken();

      // Save the user data along with the FCM token
      await _firestore.collection('users').doc(user.uid).set({
        'username': username,
        'email': email,
        'uid': user.uid,
        'isAdmin': isAdmin,
        'fcmToken': fcmToken,  // Store FCM token
      });

      await user.sendEmailVerification();
    }

    return user;
  }


  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    UserCredential userCredential = await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    User? user = userCredential.user;

    if (user != null && !user.emailVerified) {
      throw Exception('Email not verified');
    }

    return user;
  }

  Future<String?> getUsername() async {

    User? user = getCurrentUser();
    final doc = await _firestore.collection('users').doc(user?.uid).get();
    return doc.data()?['username'];

  }


  Future<bool> isAdmin() async {
    try{
      User? user = _firebaseAuth.currentUser;

      if (user != null) {
        final doc = await _firestore.collection('users').doc(user.uid).get();
        return doc.data()?['isAdmin'] == true;
      }
      else {
        throw Exception("No user is currently signed in.");
      }
    } catch(e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  Future<void> deleteUserAccount() async {
    try {
      User? user = _firebaseAuth.currentUser;

      if (user != null) {

        await _firestore.collection('users').doc(user.uid).delete();

        await user.delete();
      } else {
        throw Exception("No user is currently signed in.");
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> reAuthenticateUser(String email, String password) async {
    User? user = _firebaseAuth.currentUser;
    if (user != null) {
      AuthCredential credential = EmailAuthProvider.credential(email: email, password: password);
      await user.reauthenticateWithCredential(credential);
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  Future<void> sendEmailVerification() async {
    User? user = _firebaseAuth.currentUser;
    if(user != null && !user.emailVerified){
      await user.sendEmailVerification();
    }
  }

}
