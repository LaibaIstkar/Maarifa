import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

class SendButtonNotifier extends StateNotifier<bool> {
  SendButtonNotifier() : super(false);

  void updateState(String? text, List<File?> selectedImages) {
    final isTextValid = text != null && text.trim().isNotEmpty && text.length >= 50;
    final isEnabled = (selectedImages.isNotEmpty || isTextValid);
    state = isEnabled;
  }
}

final sendButtonProvider = StateNotifierProvider<SendButtonNotifier, bool>((ref) {
  return SendButtonNotifier();
});
