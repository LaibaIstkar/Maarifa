import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maarifa/core/theme/theme_notifier.dart';
import 'package:maarifa/features/asmaulhusna/service/audio_player_controller.dart';



class AudioPlayerWidget extends ConsumerStatefulWidget {
  const AudioPlayerWidget({super.key});

  @override
  ConsumerState<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends ConsumerState<AudioPlayerWidget> {
  final AudioPlayerController _audioPlayerController = AudioPlayerController();

  @override
  void initState() {
    super.initState();

    // Listener to update UI when position or state changes
    _audioPlayerController.onPlayerStateChanged.listen((PlayerState state) {
      if (mounted) {
        setState(() {
          _audioPlayerController.isPlaying = state == PlayerState.playing;
        });
      }
    });

    _audioPlayerController.onPositionChanged.listen((Duration position) {
      if (mounted) {
        setState(() {
          _audioPlayerController.currentDuration = position;
        });
      }
    });

    _audioPlayerController.onDurationChanged.listen((Duration duration) {
      if (mounted) {
        setState(() {
          _audioPlayerController.totalDuration = duration;
        });
      }
    });
  }

  @override
  void dispose() {
    _audioPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
     final isDarkTheme = ref.watch(themeNotifierProvider);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          IconButton(
            icon: Icon(_audioPlayerController.isPlaying
                ? Icons.pause
                : Icons.play_arrow),
            onPressed: () {
              setState(() {
                if (_audioPlayerController.isPlaying) {
                  _audioPlayerController.pauseAudio();
                } else {
                  _audioPlayerController.playAudio('audio/99_Names_of_Allah.mp3');
                }
              });
            },
          ),
          // Display time: current / total
          Text(
            '${_formatDuration(_audioPlayerController.currentDuration)} / ${_formatDuration(_audioPlayerController.totalDuration)}',
         style: TextStyle(
             color: isDarkTheme ? Colors.white : Colors.black
         ),
          ),
          // Progress Slider
          Slider(
            min: 0,
            max: _audioPlayerController.totalDuration.inSeconds.toDouble(),
            value: _audioPlayerController.currentDuration.inSeconds.toDouble(),
            onChanged: (value) {
              // Seek the audio to the selected position
              setState(() {
                _audioPlayerController.seekAudio(Duration(seconds: value.toInt()));
              });
            },
          ),
        ],
      ),
    );
  }

  // Helper function to format the duration
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }
}
