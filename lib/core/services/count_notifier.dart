import 'package:flutter_riverpod/flutter_riverpod.dart';

class UnreadCountNotifier extends StateNotifier<int> {
  UnreadCountNotifier() : super(0);

  void updateUnreadCount(int unreadCount) {
    state = unreadCount;
  }
}

final unreadCountProvider = StateNotifierProvider<UnreadCountNotifier, int>((ref) {
  return UnreadCountNotifier();
});
