import 'package:flutter_riverpod/flutter_riverpod.dart';

class ContentProvider extends StateNotifier<String> {
  ContentProvider() : super('');

  void updateContent(String newContent) {
    state = newContent;
  }
}

final contentProvider = StateNotifierProvider<ContentProvider, String>(
      (ref) => ContentProvider(),
);