import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hadith/classes.dart';
import 'package:hadith/hadith.dart';
import 'package:maarifa/core/theme/app_colors.dart';
import 'package:maarifa/core/theme/app_colors_dark.dart';
import 'package:maarifa/core/theme/theme_notifier.dart';
import 'package:maarifa/features/hadith/favorite_hadith_page.dart';
import 'package:maarifa/features/hadith/hadith_detail_page.dart';

class HadithSection extends ConsumerStatefulWidget {
  const HadithSection({super.key});

  @override
  ConsumerState<HadithSection> createState() => _HadithSectionState();
}

class _HadithSectionState extends ConsumerState<HadithSection> {
  Collections? selectedCollection;
  List<Book>? books;
  List<Hadith>? hadiths;
  int? selectedBookIndex;
  int selectedCollectionIndex = 0;

  final PageController _pageController = PageController(viewportFraction: 0.4);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      selectCollection(Collections.values[selectedCollectionIndex], selectedCollectionIndex);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void selectCollection(Collections collection, int index) async {
    var books = getBooks(collection);

    setState(() {
      selectedCollection = collection;
      selectedCollectionIndex = index;
      this.books = books;
      hadiths = null;
      selectedBookIndex = 0;
    });

    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void selectBook(int index, int bookNumber) async {
    var hadiths =  getHadiths(selectedCollection!, bookNumber);
    setState(() {
      this.hadiths = hadiths;
      selectedBookIndex = index;
    });
  }

  void onSwipeLeft() {
    if (selectedCollectionIndex > 0) {
      int newIndex = selectedCollectionIndex - 1;
      selectCollection(Collections.values[newIndex], newIndex);
    }
  }

  void onSwipeRight() {
    if (selectedCollectionIndex < Collections.values.length - 1) {
      int newIndex = selectedCollectionIndex + 1;
      selectCollection(Collections.values[newIndex], newIndex);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = ref.watch(themeNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text(
            "Hadith",
            style: TextStyle(
              fontSize: 17,
              color: isDarkTheme ? Colors.white : Colors.black,
              fontFamily: 'PoppinsBold',
            ),
          ),

            IconButton(
              icon: const Icon(Icons.favorite, color: Colors.red),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>  const FavoriteHadithPage(),
                  ),
                );
              },
            ),
            Flexible(
              child: Center(
                child: Text(
                  'Hadith Challenge',
                  style: TextStyle(
                    fontSize: 15,
                    fontFamily: 'PoppinsBold',
                    color: isDarkTheme ? AppColorsDark.purpleColor  : AppColors.spaceCadetColor,
                  ),
                ),
              ),
            ),

        ]
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDarkTheme ? Colors.white : Colors.black),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        backgroundColor: isDarkTheme ? Colors.black26 : Colors.white,

      ),
      body: GestureDetector(
        onHorizontalDragEnd: (DragEndDetails details) {
          if (details.primaryVelocity != null) {
            if (details.primaryVelocity! < 0) {
              onSwipeRight();
            } else if (details.primaryVelocity! > 0) {
              onSwipeLeft();
            }
          }
        },
        child: Column(
          children: [
            // Horizontal list for collections (books) using PageView
            SizedBox(
              height: 100, // Set a fixed height for the collection view
              child: PageView.builder(
                controller: _pageController,
                itemCount: Collections.values.length,
                onPageChanged: (index) {
                  selectCollection(Collections.values[index], index);
                },
                itemBuilder: (context, index) {
                  Collections collection = Collections.values[index];
                  bool isSelected = selectedCollectionIndex == index;

                  return GestureDetector(
                    onTap: () => selectCollection(collection, index),
                    child: Container(
                      margin: const EdgeInsets.only(left: 0.0, right: 0),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        padding: const EdgeInsets.all(10),
                        margin: isSelected ? const EdgeInsets.only(left: 0,right: 0, top: 5, bottom: 5) : const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? (isDarkTheme ? AppColorsDark.purpleColor : AppColors.primaryColorPlatinum)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10.0),
                          border: Border.all(
                            color: isSelected
                                ? (isDarkTheme ? AppColorsDark.purpleColor : AppColors.purpleColor)
                                : Colors.transparent,
                            width: 2.0,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            collection.name.toUpperCase(),
                            style: TextStyle(
                              fontFamily: isSelected ? 'PoppinsBold' : 'Poppins',
                              color: isDarkTheme ? Colors.white : Colors.black,
                              fontSize: isSelected ? 16 : 13
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Display chapters (books) in vertical list
            if (books != null)
              Expanded(
                child: ListView.builder(
                  itemCount: books!.length,
                  itemBuilder: (context, index) {
                    if (!isNumeric(books![index].bookNumber)) {
                      return const SizedBox.shrink();
                    }

                    Color tileColor = (index % 2 == 0)
                        ? (isDarkTheme ? Colors.grey[900]! : Colors.white)
                        : (isDarkTheme ? Colors.grey[850]! : Colors.grey[200]!);

                    List<BookData> bookDataList = books![index].book;
                    String arabicName = bookDataList
                        .firstWhere((element) => element.lang == 'ar', orElse: () => BookData(lang: 'ar', name: 'No Arabic Name'))
                        .name;
                    String englishName = bookDataList
                        .firstWhere((element) => element.lang == 'en', orElse: () => BookData(lang: 'en', name: 'No English Name'))
                        .name;

                    return GestureDetector(
                      onTap: () {
                        String bookNumber = books![index].bookNumber;
                        var hadiths = getHadiths(selectedCollection!, int.parse(bookNumber));

                        int bookNum = int.parse(bookNumber);

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HadithDetailPage(
                              bookNumber: bookNum,
                              hadiths: hadiths,
                              selectedCollection: selectedCollection!,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        color: tileColor,
                        child: ListTile(
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  books![index].bookNumber,
                                  style: TextStyle(
                                      color: isDarkTheme ? Colors.grey : Colors.black54,
                                      fontFamily: 'Poppins'),
                                ),
                              ),
                              const SizedBox(height: 5),
                              Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  arabicName,
                                  style: TextStyle(
                                    color: isDarkTheme ? Colors.white : Colors.black,
                                    fontSize: 16,
                                    fontFamily: 'AmiriRegularNormal',
                                  ),
                                ),
                              ),
                              const SizedBox(height: 5),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  englishName,
                                  style: TextStyle(
                                      color: isDarkTheme ? Colors.grey : Colors.black,
                                      fontSize: 14,
                                      fontFamily: 'Poppins'),
                                ),
                              ),
                              const SizedBox(height: 5),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  '${books![index].hadithStartNumber} - ${books![index].hadithEndNumber}',
                                  style: TextStyle(
                                      color: isDarkTheme ? Colors.grey : Colors.black,
                                      fontSize: 12,
                                      fontFamily: 'Poppins'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  bool isNumeric(String s) {
    return int.tryParse(s) != null;
  }
}



