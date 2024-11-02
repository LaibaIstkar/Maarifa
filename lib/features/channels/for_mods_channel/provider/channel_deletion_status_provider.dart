import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


final channelDeletionStatusProvider = StreamProvider.family<bool, String>((ref, channelId) {
  final firestore = FirebaseFirestore.instance;

  // Listen for real-time updates on the channel document
  return firestore.collection('channels').doc(channelId).snapshots().map((snapshot) {
    if (snapshot.exists) {
      final data = snapshot.data();
      final deletionScheduled = data?['deletionScheduled'] as bool? ?? false;
      final deletionTime = (data?['deletionTime'] as Timestamp?)?.toDate();

      if (deletionScheduled && deletionTime != null) {
        return DateTime.now().isBefore(deletionTime);
      }
    }
    return false;
  });
});
