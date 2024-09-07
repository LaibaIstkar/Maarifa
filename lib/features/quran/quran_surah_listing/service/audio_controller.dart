import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';





final audioControllerProvider = StateNotifierProvider<AudioController, AudioState>((ref) {
  return AudioController();
});

class AudioState {
  final bool isPlaying;
  final bool isLoading;
  final int? currentlyPlayingAyah;
  final String? errorMessage; // To hold any error message

  AudioState({
    this.isPlaying = false,
    this.isLoading = false,
    this.currentlyPlayingAyah,
    this.errorMessage,
  });

  AudioState copyWith({
    bool? isPlaying,
    bool? isLoading,
    int? currentlyPlayingAyah,
    String? errorMessage,
  }) {
    return AudioState(
      isPlaying: isPlaying ?? this.isPlaying,
      isLoading: isLoading ?? this.isLoading,
      currentlyPlayingAyah: currentlyPlayingAyah ?? this.currentlyPlayingAyah,
      errorMessage: errorMessage,
    );
  }
}


class AudioController extends StateNotifier<AudioState> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  List<String> _ayahUrls = [];
  int _currentAyahIndex = 0;

  AudioController() : super(AudioState()) {
    _audioPlayer.onPlayerComplete.listen((_) => playNextAyah());
  }

  Future<void> loadSurah(List<String> ayahUrls) async {
    _ayahUrls = ayahUrls;
    _currentAyahIndex = 0;  // Reset to start of Surah
    if (ayahUrls.isNotEmpty) {
      playAyah(_ayahUrls[_currentAyahIndex], _currentAyahIndex + 1);
    }
  }

  Future<void> playAyah(String audioUrl, int ayahNumber) async {
    state = state.copyWith(isLoading: true, currentlyPlayingAyah: ayahNumber, errorMessage: null);
    try {
      await _audioPlayer.stop(); // Stop any currently playing audio before starting a new one
      await _audioPlayer.play(UrlSource(audioUrl));
      state = state.copyWith(isPlaying: true, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isPlaying: false,
        isLoading: false,
        errorMessage: 'Audio failed to load, check your internet connection: $e',
      );
    }
  }

  void playNextAyah() {
    if (_currentAyahIndex < _ayahUrls.length - 1) {
      _currentAyahIndex++;
      playAyah(_ayahUrls[_currentAyahIndex], _currentAyahIndex + 1);
    } else {
      stopAyah();  // Stop playing after the last Ayah
    }
  }

  Future<void> pauseAyah() async {
    await _audioPlayer.pause();
    state = state.copyWith(isPlaying: false);
  }

  Future<void> stopAyah() async {
    await _audioPlayer.stop();
    state = state.copyWith(isPlaying: false, currentlyPlayingAyah: null);
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}
