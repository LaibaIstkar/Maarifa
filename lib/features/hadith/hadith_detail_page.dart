

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hadith/classes.dart';
import 'package:hadith/hadith.dart';
import 'package:hive/hive.dart';
import 'package:html/parser.dart';
import 'package:maarifa/core/theme/app_colors.dart';
import 'package:maarifa/core/theme/app_colors_dark.dart';
import 'package:maarifa/core/theme/theme_notifier.dart';
import 'package:maarifa/core/models/favoritehadithmodel/favorite_hadith.dart';

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
  bool _isSearchExpanded = false;
  late Box<FavoriteHadith> _favoritesBox;
  late bool isFavorite;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  int _loadedItemCount = 20;
  bool _isLoadingMore = false;
  List filteredHadiths = [];


  @override
  void initState() {
    super.initState();
    _favoritesBox = Hive.box<FavoriteHadith>('favorites');
  }

  void _copyToClipboard(String text, String grade, String collection) {
    Clipboard.setData(ClipboardData(text: '$text\nGrade: $grade\n $collection'));
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Copied to clipboard')));
  }

  void _toggleFavorite(String hadithNumber) {
    final hadith = widget.hadiths.firstWhere(
          (hadith) => hadith.hadithNumber == hadithNumber,
    );
    final englishHadith = hadith.hadith.firstWhere(
          (element) => element.lang == 'en',
      orElse: () => HadithData(
        lang: 'en',
        body: '',
        chapterTitle: '',
        grades: [],
        chapterNumber: '',
        urn: 0,
      ),
    );

    if (_favoritesBox.values.any((favHadith) => favHadith.hadithNumber == hadithNumber)) {
      _favoritesBox.values
          .where((favHadith) => favHadith.hadithNumber == hadithNumber)
          .forEach((favHadith) => favHadith.delete());
    } else {
      _favoritesBox.add(FavoriteHadith(
        hadithNumber: hadithNumber,
        body: parseHtmlString(englishHadith.body),
        chapterTitle: englishHadith.chapterTitle,
        grade: getHadithGrade(englishHadith.grades),
        collectionName: widget.selectedCollection.name,
      ));
    }


    setState(() {});
  }


  @override
  Widget build(BuildContext context) {
    final isDarkTheme = ref.watch(themeNotifierProvider);

    // Filter hadiths based on the search query (case-insensitive)
    filteredHadiths = widget.hadiths
        .where((hadith) => hadith.hadith.any((data) => data.lang == 'en'
        ? parseHtmlString(data.body)
        .toLowerCase()
        .contains(_searchQuery.toLowerCase())
        : false))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Visibility(
              visible: !_isSearchExpanded,
              child: Text(
                widget.selectedCollection.name.toUpperCase(),
                style: TextStyle(
                  fontSize: 17,
                  color: isDarkTheme ? Colors.white : Colors.black,
                  fontFamily: 'PoppinsBold',
                ),
              ),
            ),
            const Spacer(),
            Visibility(
              visible: !_isSearchExpanded,
              child: IconButton(
                icon: Icon(Icons.search,
                    color: isDarkTheme ? Colors.white : Colors.black),
                onPressed: () {
                  setState(() {
                    _isSearchExpanded = !_isSearchExpanded;
                  });
                },
              ),
            ),
            if (_isSearchExpanded)
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: 'Search Hadith',
                    border: InputBorder.none,
                  ),
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    color: isDarkTheme ? Colors.white : Colors.black,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
              ),
            const SizedBox(width: 8.0),
            if (_isSearchExpanded)
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  setState(() {
                    _isSearchExpanded = false;
                    _searchController.clear();
                    _searchQuery = ''; // Reset search query when closed
                  });
                },
              ),
            const SizedBox(),
          ],
        ),
        leading: Visibility(
          visible: !_isSearchExpanded,
          child: IconButton(
            icon: Icon(Icons.arrow_back,
                color: isDarkTheme ? Colors.white : Colors.black),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        backgroundColor: isDarkTheme ? Colors.black26 : Colors.white,
      ),
      body: ListView.builder(
        itemCount: _loadedItemCount < filteredHadiths.length
            ? _loadedItemCount + 1
            : filteredHadiths.length,
        itemBuilder: (context, index) {
          if (index == _loadedItemCount && _loadedItemCount < filteredHadiths.length) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _loadMoreHadiths();
            });
            return const Center(child: CircularProgressIndicator());
          }

          var hadith = filteredHadiths[index];
          HadithData? englishHadith = hadith.hadith.firstWhere(
                (element) => element.lang == 'en',
            orElse: () => HadithData(
              lang: 'en',
              body: '',
              chapterTitle: '',
              grades: [],
              chapterNumber: '',
              urn: 0,
            ),
          );

          if (englishHadith!.body.isNotEmpty) {
            String hadithBody = parseHtmlString(englishHadith.body);

            // Check if this specific hadith is a favorite
            bool isFavorite = _favoritesBox.values.any(
                    (favHadith) => favHadith.hadithNumber == hadith.hadithNumber);

            return ListTile(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDarkTheme
                              ? AppColorsDark.cardBackground
                              : AppColors.primaryColorPlatinum,
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
                      const Spacer(),
                      IconButton(
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? Colors.red : null,
                        ),
                        onPressed: () => _toggleFavorite(hadith.hadithNumber),
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy),
                        onPressed: () => _copyToClipboard(hadithBody,
                            getHadithGrade(englishHadith.grades),
                            widget.selectedCollection.name.toUpperCase()),
                      ),
                    ],
                  ),
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
            return ListTile(
              title: Text(
                  'No English Hadith available for Hadith ${hadith.hadithNumber}'),
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
        return gradeEntry['grade'];
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

  void _loadMoreHadiths() {
    // Prevent multiple calls if already loading
    if (_isLoadingMore || _loadedItemCount >= filteredHadiths.length) {
      return;
    }

    setState(() {
      _isLoadingMore = true; // Start loading
    });

    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _loadedItemCount = (_loadedItemCount + 20).clamp(0, filteredHadiths.length);
        _isLoadingMore = false;
      });
    });
  }
}
