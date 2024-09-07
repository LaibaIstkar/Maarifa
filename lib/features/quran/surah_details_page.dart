import 'package:flutter/material.dart';
import 'package:quran/quran.dart' as quran;


class SurahDetailPage extends StatelessWidget {
  final int surahIndex;
  final String surahNameArabic;
  final String surahNameEnglish;

  const SurahDetailPage({
    super.key,
    required this.surahIndex,
    required this.surahNameArabic,
    required this.surahNameEnglish,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          surahNameEnglish,
          style: const TextStyle(fontFamily: 'PoppinsBold'),
        ),
        backgroundColor: Colors.blue, // Set your preferred app bar color
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const Center(
              child: Text(
                'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                textDirection: TextDirection.rtl,
                style: TextStyle(
                  fontSize: 30,
                  fontFamily: 'AmiriRegular',
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 40),
            // Display all verses of the selected Surah
            ...List.generate(quran.getVerseCount(surahIndex), (verseIndex) {
              String verseArabic = quran.getVerse(surahIndex, verseIndex + 1, verseEndSymbol: true);
              String verseEnglish = quran.getVerseTranslation(surahIndex, verseIndex + 1);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Icons above the Arabic text
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.favorite_border, color: Colors.red, size: 17),
                        onPressed: () {
                          // Logic to favorite the verse can be added here
                          print('Verse ${verseIndex + 1} favorited');
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.play_arrow, size: 21),
                        onPressed: () {
                          // Logic to play the verse can be added here
                          print('Playing verse ${verseIndex + 1}');
                        },
                      ),
                    ],
                  ),
                  // Arabic text
                  Text(
                    verseArabic,
                    textDirection: TextDirection.rtl,
                    style: const TextStyle(
                      fontSize: 25,
                      fontFamily: 'AmiriRegular',
                      color: Colors.black,
                      height: 2.2
                    ),
                  ),
                  const SizedBox(height: 30),
                  // English translation
                  Text(
                    verseEnglish,
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'Poppins',
                      color: Colors.grey[800],
                    ),
                  ),
                  const Divider(
                    height: 40,
                    color: Colors.black26,
                  ), // Adds a visual separator between verses
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}

