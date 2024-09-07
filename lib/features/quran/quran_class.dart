import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maarifa/core/theme/app_colors.dart';
import 'package:maarifa/core/theme/app_colors_dark.dart';
import 'package:maarifa/core/theme/theme_notifier.dart';
import 'package:maarifa/features/quran/surah_details_page.dart';
import 'package:quran/quran.dart' as quran;


class QuranClass extends ConsumerStatefulWidget {
  const QuranClass({super.key});

  @override
  ConsumerState<QuranClass> createState() => _QuranClassState();
}

class _QuranClassState extends ConsumerState<QuranClass> {
  @override
  Widget build(BuildContext context) {
    final isDarkTheme = ref.watch(themeNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Quran',
          style: TextStyle(
            fontSize: 17,
            color: isDarkTheme ? Colors.white : Colors.black,
            fontFamily: 'PoppinsBold',
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDarkTheme ? Colors.white : Colors.black),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0), // Add some padding for spacing
            child: Center(
              child: Text(
                'Quran Challenge',
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'PoppinsBold',
                  color: isDarkTheme ? AppColorsDark.purpleColor  : AppColors.spaceCadetColor,
                ),
              ),
            ),
          ),
        ],
        backgroundColor: isDarkTheme ? Colors.black26 : Colors.white,
      ),
      body: ListView.builder(
        itemCount: 114, // Total number of Surahs
        itemBuilder: (context, index) {
          // Get the Surah details using the quran package
          String surahNameArabic = quran.getSurahNameArabic(index + 1);
          String surahNameEnglish = quran.getSurahName(index + 1);
          String revelationPlace = quran.getPlaceOfRevelation(index + 1);
          int verseCount = quran.getVerseCount(index + 1);

          // Determine the background color based on the index
          Color tileColor = (index % 2 == 0)
              ? (isDarkTheme ? Colors.grey[900]! : Colors.white) // Even index
              : (isDarkTheme ? Colors.grey[850]! : Colors.grey[200]!); // Odd index

          return Container(
            color: tileColor, // Set the background color
            child: ListTile(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start, // Align column content to the left
                children: [
                  // Place of Revelation and Verse Count
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '$revelationPlace - $verseCount verses',
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'Poppins',
                        color: isDarkTheme ? Colors.grey : Colors.black54,
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Align(
                    alignment: Alignment.centerRight, // Align Arabic text to the right
                    child: Text(
                      surahNameArabic,
                      textDirection: TextDirection.rtl, // Ensure RTL text direction
                      style: TextStyle(
                        fontSize: 20,
                        fontFamily: 'AmiriRegular',
                        color: isDarkTheme ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Align(
                    alignment: Alignment.centerLeft, // Align English text to the left
                    child: Text(
                      surahNameEnglish,
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'Poppins',
                        color: isDarkTheme ? Colors.grey : Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SurahDetailPage(
                      surahIndex: index + 1,
                      surahNameArabic: surahNameArabic,
                      surahNameEnglish: surahNameEnglish,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
