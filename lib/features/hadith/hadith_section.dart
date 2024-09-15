import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hadith/classes.dart';
import 'package:hadith/hadith.dart';
import 'package:maarifa/core/theme/app_colors.dart';
import 'package:maarifa/core/theme/app_colors_dark.dart';
import 'package:maarifa/core/theme/theme_notifier.dart';
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
  int? selectedBookIndex; // Track the index of the selected book
  int? selectedCollectionIndex = 0; // Track the index of the selected collection (default to first collection)

  @override
  void initState() {
    super.initState();
    // Automatically select the first collection (e.g., Bukhari) and fetch its books
    selectCollection(Collections.values[selectedCollectionIndex!], selectedCollectionIndex!);
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
  }

  void selectBook(int index, int bookNumber) async {
    var hadiths = getHadiths(selectedCollection!, bookNumber); // Fetch hadiths for the book
    setState(() {
      this.hadiths = hadiths;
      selectedBookIndex = index; // Mark this book as selected
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = ref.watch(themeNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Hadith",
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
        backgroundColor: isDarkTheme ? Colors.black26 : Colors.white,

      ),
      body: Column(
        children: [
          // Horizontal list for collections (books)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: Collections.values.asMap().entries.map((entry) {
                int index = entry.key;
                Collections collection = entry.value;
                bool isSelected = selectedCollectionIndex == index;

                return GestureDetector(
                  onTap: () => selectCollection(collection, index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: (isDarkTheme
                              ? (isSelected ? AppColorsDark.purpleColor : Colors.transparent)
                              : (isSelected ? AppColors.purpleColor : Colors.transparent)),
                          width: 3.0,
                        ),
                      ),
                    ),
                    child: Text(
                      collection.name.toUpperCase(),
                      style: TextStyle(
                        fontFamily: isSelected ? 'PoppinsBold' : 'Poppins',
                        color: isDarkTheme ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // Display chapters (books) in vertical list
          if (books != null)
          // Inside the ListView.builder for displaying chapters (books)
            Expanded(
              child: ListView.builder(
                itemCount: books!.length,
                itemBuilder: (context, index) {

                  Color tileColor = (index % 2 == 0)
                      ? (isDarkTheme ? Colors.grey[900]! : Colors.white) // Even index
                      : (isDarkTheme ? Colors.grey[850]! : Colors.grey[200]!); // Odd index

                  // Extract Arabic and English names from the book details
                  List<BookData> bookDataList = books![index].book;
                  String arabicName = bookDataList
                      .firstWhere((element) => element.lang == 'ar', orElse: () => BookData(lang: 'ar', name: 'No Arabic Name'))
                      .name;
                  String englishName = bookDataList
                      .firstWhere((element) => element.lang == 'en', orElse: () => BookData(lang: 'en', name: 'No English Name'))
                      .name;

                  return GestureDetector(
                    onTap: () => selectBook(index, books![index].bookNumber as int),
                    child: Container(
                      color: tileColor,
                      child: ListTile(
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Display the book number
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                books![index].bookNumber,
                                style: TextStyle(
                                  color: isDarkTheme ? Colors.grey : Colors.black54,
                                  fontFamily: 'Poppins'
                                ),
                              ),
                            ),
                            // Display Arabic name
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
                            // Display English name
                            const SizedBox(height: 5),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                englishName,
                                style: TextStyle(
                                    color: isDarkTheme ? Colors.grey : Colors.black,
                                    fontSize: 14,
                                  fontFamily: 'Poppins'
                                ),
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
                                    fontFamily: 'Poppins'
                                ),
                              ),
                            ),
                          ],
                        ),
                          onTap: () async {

                            print(books![index].bookNumber);
                            print(getHadithDataByNumber(Collections.ibnmajah, '266', Languages.en));

                            int bookNumber = int.parse(books![index].bookNumber);  // Convert String to int

                            print(bookNumber);

                            // Check if the book number is numeric before parsing
                            if (books![index].bookNumber.isNotEmpty) {
                              // If the book number is numeric, convert it to an integer and fetch hadiths
                              int bookNumber = int.parse(books![index].bookNumber);
                              var hadiths = getHadiths(selectedCollection!, bookNumber);

                              print(hadiths);
                              print('$bookNumber null');

                              // Navigate to HadithDetailPage with the numeric book number
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => HadithDetailPage(
                                    selectedCollection: selectedCollection!,
                                    bookNumber: bookNumber,  // Pass the book number as an int
                                    hadiths: hadiths,
                                  ),
                                ),
                              );
                            } else {
                              // Handle the case where the book number is not numeric (e.g., "introduction")
                              var hadiths = getHadiths(selectedCollection!, 0); // Adjust to handle string bookNumber



                              print('$bookNumber string');

                              print(getHadithDataByNumber(Collections.nasai, '1', Languages.en));

                              // Navigate to HadithDetailPage with a string book number (non-numeric)
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => HadithDetailPage(
                                    selectedCollection: selectedCollection!,
                                    bookNumber: bookNumber,  // Pass the book number as a string for non-numeric cases
                                    hadiths: hadiths,
                                  ),
                                ),
                              );
                            }
                          },





                    ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  bool isNumeric(String s) {
    if (s == null) {
      return false;
    }
    return int.tryParse(s) != null;
  }
}



