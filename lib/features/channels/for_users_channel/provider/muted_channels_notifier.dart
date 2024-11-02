import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MutedChannelsNotifier extends StateNotifier<List<String>> {
  MutedChannelsNotifier() : super([]);

  Future<void> fetchMutedChannels(String userId) async {
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
    if (userDoc.exists) {
      state = List<String>.from(userDoc.data()?['mutedChannels'] ?? []);
    }
  }

  Future<void> toggleMuteChannel(String userId, String channelId) async {
    final userDoc = FirebaseFirestore.instance.collection('users').doc(userId);
    if (state.contains(channelId)) {
      state = [...state]..remove(channelId);
    } else {
      state = [...state, channelId];
    }
    await userDoc.update({
      'mutedChannels': state,
    });
  }
}

final mutedChannelsProvider = StateNotifierProvider<MutedChannelsNotifier, List<String>>(
      (ref) => MutedChannelsNotifier(),
);
