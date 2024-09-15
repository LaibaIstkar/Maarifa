import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:maarifa/core/theme/app_colors.dart';
import 'package:maarifa/core/theme/app_colors_dark.dart';
import 'package:maarifa/core/theme/theme_notifier.dart';
import 'package:maarifa/features/quran/quran_surah_listing/model/ayah.dart';
import 'package:maarifa/features/quran/quran_surah_listing/model/favoriteayah.dart';
import 'package:maarifa/features/quran/quran_surah_listing/model/surah_detail.dart';
import 'package:maarifa/features/quran/quran_surah_listing/service/audio_controller.dart';
import 'package:maarifa/features/quran/quran_surah_listing/service/quran_audio_service.dart';


class SurahDetailPage extends ConsumerStatefulWidget {
  final SurahDetail surah;

  const SurahDetailPage({super.key, required this.surah});

  @override
  ConsumerState<SurahDetailPage> createState() => _SurahDetailPageState();
}

class _SurahDetailPageState extends ConsumerState<SurahDetailPage> {
  final QuranAudioService _audioService = QuranAudioService();
  late Box<FavoriteAyah> favoriteBox;
  bool _showArabicOnly = false; // Flag to toggle between views


  final bismillah  =
    "بِسْمِ ٱللَّهِ ٱلرَّحْمَـٰنِ ٱلرَّحِيمِ";


  @override
  void initState() {
    super.initState();
    // Open the Hive box for favorite ayahs
    favoriteBox = Hive.box<FavoriteAyah>('favoriteAyah');
  }

  bool isAyahFavorited(int ayahNumber) {
    return favoriteBox.values.any((favoriteAyah) => favoriteAyah.ayahNumber == ayahNumber);
  }

  void toggleFavoriteStatus(Ayah ayah, String surahName, String revelationPlace, Ayah translation) {
    if (isAyahFavorited(ayah.number)) {
      // If it's already favorited, remove it from the database
      final favoriteAyah = favoriteBox.values.firstWhere((favAyah) => favAyah.ayahNumber == ayah.number);
      favoriteAyah.delete();
    } else {
      // Add ayah to favorites
      final favoriteAyah = FavoriteAyah(
        arabicText: ayah.text,
        englishText: translation.text,
        surahName: surahName,
        revelationPlace: revelationPlace,
        ayahNumber: ayah.number,
        ayahNumberInSurah: ayah.numberInSurah,
      );
      favoriteBox.add(favoriteAyah);
    }
    setState(() {}); // Refresh UI
  }




  @override
  Widget build(BuildContext context) {
    final isDarkTheme = ref.watch(themeNotifierProvider);
    final audioState = ref.watch(audioControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text(
              widget.surah.englishName,
              style: TextStyle(
                fontSize: 20,
                fontFamily: 'PoppinsBold',
                color: isDarkTheme ? Colors.white : Colors.black,
              ),
            ),
            const Spacer(),
            IconButton(
              icon: Icon(_showArabicOnly ? Icons.notes_rounded : Icons.book_rounded),
              onPressed: () {
                setState(() {
                  _showArabicOnly = !_showArabicOnly; // Toggle the view
                });
              },
            ),
          ],
        ),
        backgroundColor: isDarkTheme ? Colors.black26 : Colors.white,
        iconTheme: IconThemeData(
          color: isDarkTheme ? Colors.white : Colors.black,
        ),
      ),
      body: _showArabicOnly
          ? Directionality(textDirection: TextDirection.rtl, child: _buildArabicOnlyView(isDarkTheme)) // Build the Arabic-only view
          : _buildDefaultView(isDarkTheme, audioState), // Build the default view
    );
  }


  // Widget _buildArabicOnlyView(bool isDarkTheme) {
  //   bool isPlaying = ref.watch(audioControllerProvider).isPlaying;
  //   bool isLoading = ref.watch(audioControllerProvider).isLoading;
  //
  //   List<InlineSpan> ayahSpans = widget.surah.ayahs.map((ayah) {
  //     return TextSpan(
  //       children: [
  //         // Ayah Text
  //         TextSpan(
  //           text: "${ayah.text.trim()} ", // Include space for separation
  //           style: TextStyle(
  //             fontSize: 25,
  //             fontFamily: 'AmiriRegular',
  //             color: isDarkTheme ? Colors.white : Colors.black,
  //           ),
  //         ),
  //         // Ayah Number inside a circular Container
  //         WidgetSpan(
  //           alignment: PlaceholderAlignment.middle,
  //           child: Container(
  //             decoration: BoxDecoration(
  //               shape: BoxShape.circle,
  //               color: isDarkTheme ? AppColorsDark.cardBackground : AppColors.primaryColorPlatinum,
  //             ),
  //             padding: const EdgeInsets.all(10), // Adjust padding as needed
  //             child: Text(
  //               ayah.numberInSurah.toString(),
  //               style: TextStyle(
  //                 fontFamily: 'Poppins',
  //                 fontSize: 13,
  //                 color: isDarkTheme ? Colors.white : Colors.black,
  //               ),
  //             ),
  //           ),
  //         ),
  //       ],
  //     );
  //   }).toList();
  //
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 60.0),
  //     child: SingleChildScrollView(
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.center,
  //         children: [
  //           Text(
  //             bismillah,
  //             textAlign: TextAlign.center,
  //             style: TextStyle(
  //               fontSize: 40,
  //               fontFamily: 'Kaleem',
  //               color: isDarkTheme ? Colors.white : Colors.black,
  //             ),
  //           ),
  //           if (isLoading)
  //             const SizedBox(height: 20),
  //           if (isLoading)
  //             LinearProgressIndicator(
  //               minHeight: 2,
  //               backgroundColor: Colors.grey[300],
  //               color: isDarkTheme ? AppColorsDark.primaryColorPlatinum : AppColors.spaceCadetColor,
  //             ),
  //           const SizedBox(height: 20),
  //           IconButton(
  //             icon: Icon(isPlaying ? Icons.stop : Icons.play_arrow, size: 21),
  //             onPressed: () async {
  //               if (isLoading) return;
  //               if (isPlaying) {
  //                 await ref.read(audioControllerProvider.notifier).stopAyah();
  //               } else {
  //                 try {
  //                   final audioUrls = await _audioService.fetchSurahAudioUrls(widget.surah.number);
  //                   ref.read(audioControllerProvider.notifier).loadSurah(audioUrls);
  //                 } catch (e) {
  //                   if (!mounted) return;
  //                   ScaffoldMessenger.of(context).showSnackBar(
  //                     SnackBar(content: Text('Sorry, failed to load audio, please check internet connection: $e')),
  //                   );
  //                 }
  //               }
  //               setState(() {});
  //             },
  //           ),
  //           const SizedBox(height: 20),
  //           RichText(
  //             textAlign: TextAlign.center,
  //             textDirection: TextDirection.rtl,
  //             text: TextSpan(children: ayahSpans),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }


  Widget _buildArabicOnlyView(bool isDarkTheme) {
    bool isPlaying = ref.watch(audioControllerProvider).isPlaying;
    bool isLoading = ref.watch(audioControllerProvider).isLoading;

    List<InlineSpan> ayahSpans = widget.surah.ayahs.map((ayah) {
      return TextSpan(
        children: [
          // Ayah Text
          TextSpan(
            text: " ${ayah.text.trim()} ", // Include space for separation
            style: TextStyle(
              fontSize: 25,
              fontFamily: 'AmiriRegularNormal',
              color: isDarkTheme ? Colors.white : Colors.black,
              height: 2.3
            ),
          ),
          // Ayah Number with background to simulate circular appearance
          TextSpan(
            text: " ${ayah.numberInSurah} ", // Space for separation
            style: TextStyle(
              fontSize: 15, // Font size adjusted
              fontFamily: 'Poppins',
              color: isDarkTheme ? Colors.white : Colors.black,
              background: Paint()
                ..color = isDarkTheme ? AppColorsDark.cardBackground : AppColors.primaryColorPlatinum
                ..style = PaintingStyle.fill,
            ),
          ),
        ],
      );
    }).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              bismillah,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 40,
                fontFamily: 'Bismillah',
                color: isDarkTheme ? Colors.white : Colors.black,
              ),
            ),
            if (isLoading)
              const SizedBox(height: 20),
            if (isLoading)
              LinearProgressIndicator(
                minHeight: 2,
                backgroundColor: Colors.grey[300],
                color: isDarkTheme ? AppColorsDark.primaryColorPlatinum : AppColors.spaceCadetColor,
              ),
            const SizedBox(height: 20),
            IconButton(
              icon: Icon(isPlaying ? Icons.stop : Icons.play_arrow, size: 21),
              onPressed: _handleAudioPlayback,
            ),
            const SizedBox(height: 20),
            RichText(
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
              text: TextSpan(children: ayahSpans),
            ),
          ],
        ),
      ),
    );
  }









  void _handleAudioPlayback() async {
    bool isPlaying = ref.read(audioControllerProvider).isPlaying;
    bool isLoading = ref.read(audioControllerProvider).isLoading;
    if (isLoading) return;
    if (isPlaying) {
      await ref.read(audioControllerProvider.notifier).stopAyah();
    } else {
      try {

        final audioUrl = await _audioService.fetchSurahAudioUrls(widget.surah.number);
        ref.read(audioControllerProvider.notifier).loadSurah(audioUrl);
      } catch (e) {

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sorry, failed to load audio, please check internet connection: $e')),
        );
      }
    }
    setState(() {});
  }








  // Function to build the default view with all icons and translations
  Widget _buildDefaultView(bool isDarkTheme, AudioState audioState) {
    return ListView.builder(
      itemCount: widget.surah.ayahs.length,
      itemBuilder: (context, index) {
        final Ayah ayah = widget.surah.ayahs[index];
        final Ayah translation = widget.surah.translations[index];

        bool isLoading = audioState.currentlyPlayingAyah == ayah.number && audioState.isLoading;
        bool isPlaying = audioState.currentlyPlayingAyah == ayah.number && audioState.isPlaying;
        bool isFavorited = isAyahFavorited(ayah.number); // Check if Ayah is favorited

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
                        icon: Icon(
                          isFavorited ? Icons.favorite : Icons.favorite_border,
                          color: isFavorited ? Colors.red : Colors.grey,
                          size: 17,
                        ),
                        onPressed: () {
                          toggleFavoriteStatus(
                            ayah,
                            widget.surah.englishName,
                            widget.surah.revelationType,
                            translation,
                          );
                        },
                      ),
                      IconButton(
                        icon: isPlaying
                            ? const Icon(Icons.stop, size: 21)
                            : const Icon(Icons.play_arrow, size: 21),
                        onPressed: () async {
                          if (isLoading) return;

                          if (isPlaying) {
                            await ref.read(audioControllerProvider.notifier).stopAyah();
                            setState(() {});
                          } else {
                            try {
                              setState(() {});
                              final audioUrl = await _audioService.fetchAyahAudioUrl(ayah.number);
                              await ref.read(audioControllerProvider.notifier).playAyah(audioUrl, ayah.number);
                            } catch (e) {
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Sorry, failed to load audio, please check internet connection: $e'),
                                ),
                              );
                            }
                          }
                        },
                      ),
                    ],
                  ),
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDarkTheme ? AppColorsDark.cardBackground : AppColors.primaryColorPlatinum,
                    ),
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      ayah.numberInSurah.toString(),
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

              // Arabic Ayah text
              Text(
                ayah.text,
                textDirection: TextDirection.rtl,
                style: TextStyle(
                  fontSize: 25,
                  fontFamily: 'AmiriRegularNormal',
                  color: isDarkTheme ? Colors.white : Colors.black,
                  height: 2.2,
                ),
              ),
              const SizedBox(height: 30),

              // Translation
              Text(
                translation.text,
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'Poppins',
                  color: isDarkTheme ? Colors.white70 : Colors.black54,
                ),
              ),
              Divider(
                height: 40,
                color: isDarkTheme ? Colors.grey : Colors.black26,
              ),
            ],
          ),
        );
      },
    );
  }
}



