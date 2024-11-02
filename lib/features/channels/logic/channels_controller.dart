import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maarifa/core/models/channel_model/channel.dart';
import 'package:maarifa/core/models/post_model/post.dart';
import 'package:maarifa/core/services/report_service.dart';
import 'package:flutter/material.dart';

final channelControllerProvider = Provider<ChannelController>((ref) {
  return ChannelController();
});

class ChannelController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ReportService reportService = ReportService();



  Future<void> createChannel(String userId, String description, String title, String purpose, String coverPhoto, String user) async {
    final userChannelsQuery = await _firestore.collection('channels')
        .where('creatorId', isEqualTo: userId)
        .get();

    if (userChannelsQuery.docs.length > 3) {
      throw Exception('You cannot create more than 3 channels.');
    }

    await _firestore.collection('channels').add({
      'description': description,
      'title': title,
      'purpose': purpose,
      'creatorId': userId,
      'coverPhoto': coverPhoto,
      'approved': false,
      'user': user,
    });
  }


  Stream<List<Channel>> getApprovedChannels() {
    return _firestore.collection('channels').where('approved', isEqualTo: true).snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Channel.fromFirestore(doc)).toList());
  }

  Future<bool> isTitleUnique(String title) async {
    final querySnapshot = await _firestore
        .collection('channels')
        .where('title', isEqualTo: title)
        .get();

    return querySnapshot.docs.isEmpty;
  }

  Future<void> joinChannel(String userId, String username, String channelId) async {
    try {
      // Add user to the channel's members collection
      await _firestore.collection('channels').doc(channelId).collection('members').doc(userId).set({
        'username': username,
      });

      // Add the channel to the user's joined channels with initial metadata
      await _firestore.collection('users').doc(userId).update({
        'joinedChannels.$channelId': {
          'lastRead': FieldValue.serverTimestamp(), // Initialize lastRead as current time
        }
      });

    } catch (e) {
      throw Exception('Failed to join channel: $e');
    }
  }


  Future<void> leaveChannel(String userId, String channelId) async {
    try {
      // Remove user from the channel's members collection
      await _firestore.collection('channels').doc(channelId).collection('members').doc(userId).delete();

      // Remove the channel from the user's joined channels map
      await _firestore.collection('users').doc(userId).update({
        'joinedChannels.$channelId': FieldValue.delete(), // Remove channel from map
      });

    } catch (e) {
      throw Exception('Failed to leave channel: $e');
    }
  }


  Stream<List<String>> getJoinedChannels(String userId) {
    return _firestore.collection('users').doc(userId).snapshots().map((doc) {
      final userData = doc.data();
      final Map<String, dynamic> joinedChannels = userData?['joinedChannels'] ?? {};

      // Return the list of channel IDs (keys from the map)
      return joinedChannels.keys.toList().cast<String>();
    });
  }


  Stream<List<Channel>> getJoinedChannelsWithDetails(String userId) async* {
    final userDocStream = _firestore.collection('users').doc(userId).snapshots();

    await for (final userDocSnapshot in userDocStream) {
      final Map<String, dynamic> joinedChannelsData = userDocSnapshot.data()?['joinedChannels'] ?? {};

      List<Channel> joinedChannels = [];

      for (String channelId in joinedChannelsData.keys) {
        // Fetch the channel document stream from the channels collection
        final channelDocSnapshot = await _firestore.collection('channels').doc(channelId).get();
        if (channelDocSnapshot.exists) {
          joinedChannels.add(Channel.fromFirestore(channelDocSnapshot));
        }
      }

      yield joinedChannels; // Emit the updated list of joined channels
    }
  }



  Future<List<Channel>> getCreatedChannels(String userId) async {
    final querySnapshot = await _firestore
        .collection('channels')
        .where('creatorId', isEqualTo: userId)
        .get();
    return querySnapshot.docs.map((doc) => Channel.fromFirestore(doc)).toList();
  }

  Future<void> postContent(String channelId, String content, {List<String>? imageUrls}) async {
    await _firestore.collection('posts').add({
      'channelId': channelId,
      'content': content,
      'images': imageUrls ?? [],
      'timestamp': FieldValue.serverTimestamp(),
      'reactions': {},
    });
  }

  static final Map<String, bool> _isCreatorCache = {};

  Future<bool> isChannelCreator(String userId, String channelId) async {
    if (_isCreatorCache.containsKey(channelId)) {
      return _isCreatorCache[channelId]!;
    }

    try {
      final channelDoc = await _firestore.collection('channels').doc(channelId).get();

      if (channelDoc.exists && channelDoc.data() != null) {
        final channelData = channelDoc.data()!;
        final String? creatorId = channelData['creatorId'];

        final bool isCreator = creatorId != null && creatorId == userId;

        _isCreatorCache[channelId] = isCreator;

        return isCreator;
      }

      _isCreatorCache[channelId] = false;
      return false;
    } catch (e) {
      throw Exception('Error checking channel creator: $e');
    }
  }

  // Static method to access the cached value (non-async)
  static bool getCachedIsCreator(String channelId) {
    return _isCreatorCache[channelId] ?? false; // Return false if not cached
  }


  Future<void> scheduleChannelDeletion(String channelId) async {
    try {
      final deletionTime = DateTime.now().add(const Duration(days: 3));

      // 1. Post a red-colored deletion warning to the channel
      await _firestore.collection('posts').add({
        'channelId': channelId,
        'content': 'Unfortunately, this channel is going to be deleted in 3 days... :(',
        'timestamp': DateTime.now(),
        'isDeletionWarning': true,
        'reactions': {},
        'images': []
      });

      // 2. Mark the channel as scheduled for deletion
      await _firestore.collection('channels').doc(channelId).update({
        'deletionScheduled': true,
        'deletionTime': deletionTime,
      });


    } catch (e) {
      throw Exception('Failed to schedule channel deletion: $e');
    }
  }


  Future<void> deletePost(String channelId, String postId, List<String> imageUrls) async {
    try {
      final querySnapshot = await _firestore
          .collection('posts')
          .where('channelId', isEqualTo: channelId)
          .where(FieldPath.documentId, isEqualTo: postId)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        await _firestore.collection('posts').doc(postId).delete();

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

  Future<void> updatePost(String channelId, String postId, String newContent) async {
    try {
      final querySnapshot = await _firestore
          .collection('posts')
          .where('channelId', isEqualTo: channelId)
          .where(FieldPath.documentId, isEqualTo: postId)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        await _firestore.collection('posts').doc(postId).update({
          'content': newContent,
        });

      } else {
        throw Exception('Post not found');
      }
    } catch (e) {
      throw Exception('Failed to update post');
    }
  }

  Stream<List<Post>> getChannelPosts(String channelId) {
    return _firestore
        .collection('posts')
        .where('channelId', isEqualTo: channelId)
        .orderBy('timestamp', descending: false) // Order by timestamp
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Post.fromFirestore(doc)).toList());
  }

  Future<void> reactToPost(String postId, String? userId, String emoji) async {
    await _firestore.collection('posts').doc(postId).update({
      'reactions.$userId': emoji,
    });
  }

  Future<void> reportPost(String channelId, String channelName, String postId, String reportMessage, BuildContext context) async {
    final currentUser = FirebaseAuth.instance.currentUser!;
    final userId = currentUser.uid;

    final existingReport = await FirebaseFirestore.instance
        .collection('reports')
        .where('postId', isEqualTo: postId)
        .where('reportedBy', isEqualTo: userId)
        .get();

    if (existingReport.docs.isNotEmpty) {

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You have already reported this post!')),
      );
      return;
    }

    await FirebaseFirestore.instance.collection('reports').add({
      'type': 'post',
      'channelId': channelId,
      'channelName': channelName,
      'postId': postId,
      'reportMessage': reportMessage,
      'reportTimestamp': Timestamp.now(),
      'reportedBy': userId,
    });

    await reportService.checkReportAndSendEmail(channelId, postId, channelName, 'post');

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Post reported successfully!')),
    );
  }

  Future<void> reportChannel(String channelId, String channelName, String reportMessage, BuildContext context) async {
    final currentUser = FirebaseAuth.instance.currentUser!;
    final userId = currentUser.uid;

    final existingReport = await FirebaseFirestore.instance
        .collection('reports')
        .where('channelId', isEqualTo: channelId)
        .where('type', isEqualTo: 'channel')
        .where('reportedBy', isEqualTo: userId)
        .get();

    if (existingReport.docs.isNotEmpty) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You have already reported this channel!'),
          behavior: SnackBarBehavior.floating,),
      );
      return;
    }

    await FirebaseFirestore.instance.collection('reports').add({
      'type': 'channel',
      'channelId': channelId,
      'channelName': channelName,
      'reportMessage': reportMessage,
      'reportTimestamp': Timestamp.now(),
      'reportedBy': userId,
    });

    await reportService.checkReportAndSendEmail(channelId, null, channelName, 'channel');

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Channel reported successfully!'),
      behavior: SnackBarBehavior.floating,),
    );
  }

}

