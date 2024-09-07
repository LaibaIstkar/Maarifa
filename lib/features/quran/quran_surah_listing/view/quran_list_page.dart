import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maarifa/core/theme/app_colors.dart';
import 'package:maarifa/core/theme/app_colors_dark.dart';
import 'package:maarifa/core/theme/theme_notifier.dart';
import 'package:maarifa/features/quran/quran_surah_listing/model/surah.dart';
import 'package:maarifa/features/quran/quran_surah_listing/view/favorite_ayahs_page.dart';
import 'package:maarifa/features/quran/quran_surah_listing/view/surah_details_page.dart';
import 'package:maarifa/features/quran/quran_surah_listing/viewmodel/quran_view_model.dart';

class QuranListPage extends ConsumerStatefulWidget {
  const QuranListPage({super.key});

  @override
  ConsumerState<QuranListPage> createState() => _QuranListPageState();
}


class _QuranListPageState extends ConsumerState<QuranListPage> {
  bool _isSearchExpanded = false;
  final TextEditingController _searchController = TextEditingController();
  List<Surah> _filteredSurahs = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    ref.read(quranViewModelProvider.notifier).fetchAndStoreSurah();
    for (int i = 1; i <= 114; i++) {
      ref.read(quranViewModelProvider.notifier).fetchSurahDetail(i);
    }
  }

  @override
  Widget build(BuildContext context) {
    final surahs = ref.watch(quranViewModelProvider);
    final isDarkTheme = ref.watch(themeNotifierProvider);

    // Filter surahs based on the search query
    _filteredSurahs = _searchQuery.isEmpty
        ? surahs // If search is empty, show all surahs
        : surahs.where((surah) => surah.englishName.toLowerCase().contains(_searchQuery.toLowerCase())).toList();

    return Scaffold(
      appBar: AppBar(
        title: Row( // Use Row for horizontal layout of elements
          children: [
            Visibility(
              visible: !_isSearchExpanded,
              child: Text(
                'Quran',
                style: TextStyle(
                  fontSize: 17,
                  color: isDarkTheme ? Colors.white : Colors.black,
                  fontFamily: 'PoppinsBold',
                ),
              ),
            ),
            Visibility(
              visible: !_isSearchExpanded,
              child: IconButton(
                icon: const Icon(Icons.favorite, color: Colors.red),
                onPressed: () {
                  // Navigate to FavoriteAyahsPage when heart button is clicked
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const FavoriteAyahsPage(),
                    ),
                  );
                },
              ),
            ),
            Visibility(
              visible: !_isSearchExpanded,
              child: IconButton(
                icon: Icon(Icons.search, color: isDarkTheme ? Colors.white : Colors.black),
                onPressed: () {
                  setState(() {
                    _isSearchExpanded = !_isSearchExpanded;
                  });
                  // Optionally clear search text on collapse
                  if (!_isSearchExpanded) {
                    _searchController.clear();
                    _searchQuery = ''; // Clear the search query
                  }
                },
              ),
            ),
            if (_isSearchExpanded) // Only show search input when expanded
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: 'Search Quran',
                    border: InputBorder.none, // Remove default border for cleaner look
                  ),
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    color: isDarkTheme ? Colors.white : Colors.black,
                  ),
                  onChanged: (value) {
                    // Update the search query and filter surahs
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
            Visibility(
              visible: !_isSearchExpanded,
              child: Expanded(
                child: Center(
                  child: Text(
                    'Quran Challenge',
                    style: TextStyle(
                      fontSize: 15,
                      fontFamily: 'PoppinsBold',
                      color: isDarkTheme ? AppColorsDark.purpleColor  : AppColors.spaceCadetColor,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        leading: Visibility(
          visible: !_isSearchExpanded,
          child: IconButton(
            icon: Icon(Icons.arrow_back, color: isDarkTheme ? Colors.white : Colors.black),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        backgroundColor: isDarkTheme ? Colors.black26 : Colors.white,
      ),
      body: surahs.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: _filteredSurahs.length,
        itemBuilder: (context, index) {
          final surah = _filteredSurahs[index];

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
                      '${surah.revelationType} - ${surah.numberOfAyahs} verses',
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
                      surah.name,
                      textDirection: TextDirection.rtl, // Ensure RTL text direction
                      style: TextStyle(
                        fontSize: 20,
                        fontFamily: 'AmiriRegularNormal',
                        color: isDarkTheme ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Align(
                    alignment: Alignment.centerLeft, // Align English text to the left
                    child: Text(
                      surah.englishName,
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
                _onSurahSelected(context, surah.number);
              },
            ),
          );
        },
      ),
    );
  }

  void _onSurahSelected(BuildContext context, int surahNumber) async {
    final viewModel = ref.read(quranViewModelProvider.notifier);
    try {
      final surahDetail = await viewModel.fetchSurahDetail(surahNumber);
      if(!context.mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SurahDetailPage(surah: surahDetail),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sorry, failed to load surah details, please check internet connection: $e')),
      );
    }
  }
}




