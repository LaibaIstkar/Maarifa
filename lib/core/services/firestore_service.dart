import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addUserData(String uid, String username, String email) async {
    await _firestore.collection('users').doc(uid).set({
      'username': username,
      'email': email,
    });
  }

  Future<bool> isUsernameUnique(String username) async {
    final QuerySnapshot result = await _firestore
        .collection('users')
        .where('username', isEqualTo: username)
        .get();

    return result.docs.isEmpty;
  }
}
