

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hadith/classes.dart';
import 'package:hadith/hadith.dart';
import 'package:html/parser.dart';
import 'package:maarifa/core/theme/app_colors.dart';
import 'package:maarifa/core/theme/app_colors_dark.dart';
import 'package:maarifa/core/theme/theme_notifier.dart';


class HadithDetailPage extends ConsumerStatefulWidget {
  final Collections selectedCollection;
  final int bookNumber;
  final List<Hadith> hadiths;

  const HadithDetailPage({
    super.key,
    required this.selectedCollection,
    required this.bookNumber,
    required this.hadiths,
  });

  @override
  ConsumerState<HadithDetailPage> createState() => _HadithDetailPageState();
}

class _HadithDetailPageState extends ConsumerState<HadithDetailPage> {
  @override
  Widget build(BuildContext context) {
    final isDarkTheme = ref.watch(themeNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.selectedCollection.name.toUpperCase(),
          style: TextStyle(
          fontSize: 15,
          fontFamily: 'PoppinsBold',
          color: isDarkTheme ? Colors.white : Colors.black,
        ),
        ),
      ),
      body: ListView.builder(
        itemCount: widget.hadiths.length,
        itemBuilder: (context, index) {
          var hadith = widget.hadiths[index];

          // Extract English hadith data from List<HadithData>
          HadithData? englishHadith = hadith.hadith.firstWhere(
                (element) => element.lang == 'en',
            orElse: () => HadithData(lang: 'en', body: '', chapterTitle: '', grades: [], chapterNumber: '', urn: 0),
          );

          // Ensure englishHadith is not null
          if (englishHadith.body.isNotEmpty) {
            // Parse the body to display it properly
            String hadithBody = parseHtmlString(englishHadith.body); // If you want to clean up HTML tags

            print(hadithBody);

            return ListTile(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDarkTheme ? AppColorsDark.cardBackground : AppColors.primaryColorPlatinum,
                    ),
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      hadith.hadithNumber,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        color: isDarkTheme ? Colors.white : Colors.black,
                      ),
                    ),
                  ),

                  // Conditionally render Chapter Title and SizedBox
                  if (englishHadith.chapterTitle.isNotEmpty) ...[
                    const SizedBox(height: 5),
                    Text(
                      englishHadith.chapterTitle,
                      style: TextStyle(
                        fontSize: 17,
                        fontFamily: 'PoppinsBold',
                        color: isDarkTheme ? Colors.white : Colors.black,
                      ),
                    ),
                  ],

                  // Display Hadith Body
                  const SizedBox(height: 5),
                  Text(
                    hadithBody,
                    style: TextStyle(
                      fontSize: 17,
                      fontFamily: 'Poppins',
                      color: isDarkTheme ? Colors.white : Colors.black,
                    ),
                    textAlign: TextAlign.justify,
                  ),

                  const SizedBox(height: 5),
                  Text(
                    'Grade: ${getHadithGrade(englishHadith.grades)}',
                    style: TextStyle(
                      fontSize: 13,
                      fontFamily: 'PoppinsBold',
                      color: isDarkTheme ? Colors.white60 : Colors.black54,
                    ),
                  ),

                  const SizedBox(height: 8),
                  Divider(
                    height: 40,
                    color: isDarkTheme ? Colors.grey : Colors.black26,
                  ),
                ],
              ),
            );
          } else {
            // If no English version is available, display a fallback
            return ListTile(
              title: Text('No English Hadith available for Hadith ${hadith.hadithNumber}'),
            );
          }
        },
      ),
    );
  }

  String getHadithGrade(List<dynamic> grades) {
    if (grades.isNotEmpty) {
      var gradeEntry = grades[0];
      if (gradeEntry is Map<String, dynamic> && gradeEntry['grade'] != null) {
        return gradeEntry['grade']; // Assuming the first grade is relevant
      }
    }
    return 'No grade available';
  }

  String parseHtmlString(String htmlString) {
    final document = parse(htmlString);

    String parsedString = document.body?.text ?? htmlString;

    parsedString = parsedString.replaceAll(RegExp(r'\s+'), ' ').trim();
    return parsedString;
  }

}
