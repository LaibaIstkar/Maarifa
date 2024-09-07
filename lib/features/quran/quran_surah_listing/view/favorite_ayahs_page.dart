


import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:maarifa/core/theme/app_colors.dart';
import 'package:maarifa/core/theme/app_colors_dark.dart';
import 'package:maarifa/core/theme/theme_notifier.dart';
import 'package:maarifa/features/quran/quran_surah_listing/model/favoriteayah.dart';
import 'package:maarifa/features/quran/quran_surah_listing/service/audio_controller.dart';
import 'package:maarifa/features/quran/quran_surah_listing/service/quran_audio_service.dart';

class FavoriteAyahsPage extends ConsumerStatefulWidget {
  const FavoriteAyahsPage({Key? key}) : super(key: key);

  @override
  ConsumerState<FavoriteAyahsPage> createState() => _FavoriteAyahsPageState();
}

class _FavoriteAyahsPageState extends ConsumerState<FavoriteAyahsPage> {
  final QuranAudioService _audioService = QuranAudioService();
  late Box<FavoriteAyah> favoriteBox;

  @override
  void initState() {
    super.initState();
    // Open the Hive box for favorite ayahs
    favoriteBox = Hive.box<FavoriteAyah>('favoriteAyah');
  }

  void toggleFavoriteStatus(FavoriteAyah favoriteAyah) {
    favoriteAyah.delete();
    setState(() {}); // Refresh UI after unfavoriting
  }

  bool isAyahPlaying(int ayahNumber, int? currentlyPlayingAyah) {
    return ayahNumber == currentlyPlayingAyah;
  }

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = ref.watch(themeNotifierProvider);
    final audioState = ref.watch(audioControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Favorite Ayahs',
          style: TextStyle(
          fontSize: 20,
          fontFamily: 'PoppinsBold',
          color: isDarkTheme ? Colors.white : Colors.black,
          ),
        ),
        backgroundColor: isDarkTheme ? Colors.black26 : Colors.white,
        iconTheme: IconThemeData(
          color: isDarkTheme ? Colors.white : Colors.black,
        ),
      ),
      body: favoriteBox.isEmpty
          ? Center(
        child: Text(
          'No favorite ayahs added yet.',
          style: TextStyle(
            color: isDarkTheme ? Colors.white : Colors.black,
            fontFamily: 'Poppins',
          ),
        ),
      )
          : ListView.builder(
        itemCount: favoriteBox.length,
        itemBuilder: (context, index) {
          final FavoriteAyah favoriteAyah = favoriteBox.getAt(index)!;
          //
          // bool isPlaying = isAyahPlaying(favoriteAyah.ayahNumber, audioState.currentlyPlayingAyah);
          // bool isLoading = isPlaying && audioState.isLoading;

          bool isLoading = audioState.currentlyPlayingAyah == favoriteAyah.ayahNumber && audioState.isLoading;
          bool isPlaying = audioState.currentlyPlayingAyah == favoriteAyah.ayahNumber && audioState.isPlaying;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.favorite,
                            color: Colors.red,
                            size: 17,
                          ),
                          onPressed: () {
                            // Unfavorite logic
                            toggleFavoriteStatus(favoriteAyah);
                          },
                        ),
                        IconButton(
                          icon: isPlaying
                              ? const Icon(Icons.pause, size: 21)
                              : const Icon(Icons.play_arrow, size: 21),
                          onPressed: () async {
                            if (isLoading) return;

                            if (isPlaying) {
                              // Pause the currently playing Ayah
                              await ref.read(audioControllerProvider.notifier).pauseAyah();
                              setState(() {}); // Ensure the UI updates after pressing pause
                            } else {
                              try {
                                final audioUrl = await _audioService.fetchAyahAudioUrl(favoriteAyah.ayahNumber);
                                await ref.read(audioControllerProvider.notifier).playAyah(audioUrl, favoriteAyah.ayahNumber);
                              } catch (e) {
                                print('Error playing ayah audio: $e');
                              }
                            }
                            setState(() {}); // Ensure the UI updates after pressing play
                          },
                        ),
                      ],
                    ),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5.0),
                        shape: BoxShape.rectangle,
                        color: isDarkTheme
                            ? AppColorsDark.cardBackground
                            : AppColors.primaryColorPlatinum,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10),
                      child: Text(
                        '${favoriteAyah.surahName} : ${favoriteAyah.ayahNumberInSurah}',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13,
                          color: isDarkTheme ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
                if (isLoading)
                  LinearProgressIndicator(
                    minHeight: 2,
                    backgroundColor: Colors.grey[300],
                    color: isDarkTheme ? AppColorsDark.primaryColorPlatinum : AppColors.spaceCadetColor,
                  ),
                const SizedBox(height: 5),
                // Arabic Text
                Text(
                  favoriteAyah.arabicText,
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                    fontSize: 25,
                    fontFamily: 'AmiriRegular',
                    color: isDarkTheme ? Colors.white : Colors.black,
                    height: 2.2,
                  ),
                ),
                const SizedBox(height: 30),
                // English Translation
                Text(
                  favoriteAyah.englishText,
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'Poppins',
                    color: isDarkTheme ? Colors.white70 : Colors.black54,
                  ),
                ),
                const SizedBox(height: 10),
                // Revelation Type and Surah Name
                Text(
                  favoriteAyah.revelationPlace,
                  style: TextStyle(
                    fontSize: 13,
                    fontFamily: 'Poppins',
                    color: isDarkTheme ? Colors.white54 : Colors.black45,
                  ),
                ),
                Divider(
                  height: 40,
                  color: isDarkTheme ? Colors.grey : Colors.black26,
                ), // Adds a visual separator between ayahs
              ],
            ),
          );
        },
      ),
    );
  }
}

