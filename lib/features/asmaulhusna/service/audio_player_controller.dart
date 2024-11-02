import 'package:audioplayers/audioplayers.dart';



class AudioPlayerController {
  final AudioPlayer _audioPlayer = AudioPlayer();
  Duration totalDuration = Duration.zero;
  Duration currentDuration = Duration.zero;
  bool isPlaying = false;

  AudioPlayerController() {
    // Listener for total audio duration
    _audioPlayer.onDurationChanged.listen((Duration duration) {
      totalDuration = duration;
    });

    // Listener for current position of the audio
    _audioPlayer.onPositionChanged.listen((Duration position) {
      currentDuration = position;
    });

    // Listener for player state changes
    _audioPlayer.onPlayerStateChanged.listen((PlayerState state) {
      isPlaying = state == PlayerState.playing;
    });
  }

  // Expose the streams so that they can be accessed publicly
  Stream<Duration> get onDurationChanged => _audioPlayer.onDurationChanged;
  Stream<Duration> get onPositionChanged => _audioPlayer.onPositionChanged;
  Stream<PlayerState> get onPlayerStateChanged => _audioPlayer.onPlayerStateChanged;

  // Function to play audio
  void playAudio(String path) async {
    await _audioPlayer.play(AssetSource(path));
  }

  // Function to pause audio
  void pauseAudio() async {
    await _audioPlayer.pause();
  }

  // Function to seek audio
  void seekAudio(Duration position) {
    _audioPlayer.seek(position);
  }

  void dispose() {
    _audioPlayer.dispose();
  }
}

