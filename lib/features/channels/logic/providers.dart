


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maarifa/core/models/post_model/post.dart';
import 'package:maarifa/features/auth/view_model/auth_view_model.dart';

final lastReadProvider = StreamProvider.family<DateTime?, String>((ref, channelId) {
  final currentUser = ref.read(authViewModelProvider).getCurrentUser()?.uid;
  final userDocStream = FirebaseFirestore.instance
      .collection('users')
      .doc(currentUser)
      .snapshots();

  return userDocStream.map((snapshot) {
    if (snapshot.exists) {
      final data = snapshot.data() as Map<String, dynamic>;
      if (data['joinedChannels'] != null &&
          data['joinedChannels'][channelId] != null) {
        return (data['joinedChannels'][channelId]['lastRead'] as Timestamp).toDate();
      }
    }
    return null;
  });
});


final lastPostProvider = StreamProvider.family<Post?, String>((ref, channelId) {
  return FirebaseFirestore.instance
      .collection('posts')
      .where('channelId', isEqualTo: channelId)
      .orderBy('timestamp', descending: true)
      .limit(1)
      .snapshots()
      .map((snapshot) {
    if (snapshot.docs.isNotEmpty) {
      return Post.fromFirestore(snapshot.docs.first);
    }
    return null;
  });
});
