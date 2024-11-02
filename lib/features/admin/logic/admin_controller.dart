import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:maarifa/core/models/channel_model/channel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maarifa/core/models/post_model/post.dart';

class AdminController extends StateNotifier<List<Channel>> {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  AdminController(this._firestore) : super([]);

  Stream<List<Channel>> getPendingChannels() {
    return _firestore
        .collection('channels')
        .where('approved', isEqualTo: false) // Fetching only unapproved channels
        .snapshots()
        .map((snapshot) {

      return snapshot.docs.map((doc) => Channel.fromFirestore(doc)).toList();
    });
  }


  Future<void> approveChannel(String channelId) async {
    await _firestore.collection('channels').doc(channelId).update({'approved': true});
  }

  Future<void> disapproveChannel(String channelId) async {
    await _firestore.collection('channels').doc(channelId).delete();
  }


  Stream<List<Post>> getChannelPosts(String channelId) {
    return _firestore
        .collection('posts')
        .where('channelId', isEqualTo: channelId)
        .orderBy('timestamp', descending: false) // Order by timestamp
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Post.fromFirestore(doc)).toList());
  }

  ///////////////////////////

  Future<List<Channel>> getCreatedChannels(String userId) async {
    final querySnapshot = await _firestore
        .collection('channels')
        .where('creatorId', isEqualTo: userId)
        .get();
    return querySnapshot.docs.map((doc) => Channel.fromFirestore(doc)).toList();
  }

  Future<List<Channel>> getApprovedChannels() async {
    final querySnapshot = await _firestore
        .collection('channels')
        .where('approved', isEqualTo: true)
        .get();
    return querySnapshot.docs.map((doc) => Channel.fromFirestore(doc)).toList();
  }

  ///////////////////////////

  Future<void> reactToPost(String postId, String? userId, String emoji) async {
    await _firestore.collection('posts').doc(postId).update({
      'reactions.$userId': emoji,
    });
  }

  Future<void> deleteChannel(String channelId) async {
    try {
      final channelDoc = await _firestore.collection('channels').doc(channelId).get();

      if (channelDoc.exists) {
        // 1. Delete the channel document
        await _firestore.collection('channels').doc(channelId).delete();

        // 2. Delete posts associated with the channel (optional)
        final postsQuery = await _firestore
            .collection('posts')
            .where('channelId', isEqualTo: channelId)
            .get();

        for (var doc in postsQuery.docs) {
          final String postId = doc.id;
          final List<String> imageUrls = doc.data()['images'] as List<String>;
          await deletePost(channelId, postId, imageUrls);
        }

        // 3. Remove the channel from joined channels of members
        final membersQuery = await _firestore
            .collection('channels')
            .doc(channelId)
            .collection('members')
            .get();

        for (var memberDoc in membersQuery.docs) {
          final String userId = memberDoc.id;
          await _firestore.collection('users').doc(userId).update({
            'joinedChannels': FieldValue.arrayRemove([
              {'id': channelId},
            ]),
          });
        }

      } else {
        throw Exception('Channel not found');
      }
    } catch (e) {
      throw Exception('Failed to delete channel');
    }
  }

  Future<void> deleteExpiredChannels() async {
    try {
      final now = DateTime.now();

      // Query channels that are scheduled for deletion and whose deletion time has passed
      final querySnapshot = await _firestore
          .collection('channels')
          .where('deletionScheduled', isEqualTo: true)
          .where('deletionTime', isLessThan: now)
          .get();

      // Iterate over channels and delete them
      for (var channelDoc in querySnapshot.docs) {
        final String channelId = channelDoc.id;
        await deleteChannel(channelId);
      }
    } catch (e) {
      throw Exception('Failed to delete expired channels: $e');
    }
  }


  Future<void> deletePost(String channelId, String postId, List<String> imageUrls) async {
    try {
      // Find the post with the given postId and channelId in the 'posts' collection
      final querySnapshot = await _firestore
          .collection('posts')
          .where('channelId', isEqualTo: channelId)
          .where(FieldPath.documentId, isEqualTo: postId)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Delete the post document
        await _firestore.collection('posts').doc(postId).delete();

        // Delete associated images from Firebase Storage
        for (String imageUrl in imageUrls) {
          final storageRef = _storage.refFromURL(imageUrl);
          await storageRef.delete();
        }

      } else {
        throw Exception('Post not found');
      }
    } catch (e) {
      throw Exception('Failed to delete post');
    }
  }

}




// Riverpod provider for AdminController
final adminControllerProvider = StateNotifierProvider<AdminController, List<Channel>>((ref) {
  return AdminController(FirebaseFirestore.instance);
});

final adminChannelControllerProvider = Provider<AdminController>((ref) {
  return AdminController(FirebaseFirestore.instance);
});