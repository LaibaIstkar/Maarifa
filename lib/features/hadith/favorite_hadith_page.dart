import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:maarifa/core/theme/app_colors.dart';
import 'package:maarifa/core/theme/app_colors_dark.dart';
import 'package:maarifa/core/theme/theme_notifier.dart';
import 'package:maarifa/core/models/favoritehadithmodel/favorite_hadith.dart';

class FavoriteHadithPage extends ConsumerStatefulWidget {
  const FavoriteHadithPage({super.key});

  @override
  ConsumerState<FavoriteHadithPage> createState() => _FavoriteHadithPageState();
}

class _FavoriteHadithPageState extends ConsumerState<FavoriteHadithPage> {
  late Box<FavoriteHadith> _favoritesBox;

  @override
  void initState() {
    super.initState();
    _favoritesBox = Hive.box<FavoriteHadith>('favorites');
  }

  void _removeFromFavorites(String hadithNumber) {
    // Remove the Hadith from the favorites box
    setState(() {
      _favoritesBox.values
          .where((favHadith) => favHadith.hadithNumber == hadithNumber)
          .forEach((favHadith) => favHadith.delete());
    });
  }

  void _copyToClipboard(String text, String grade, String collection) {
    Clipboard.setData(ClipboardData(text: '$text\nGrade: $grade\n $collection'));
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Copied to clipboard')));
  }

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = ref.watch(themeNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title:  Text(
          'Favorite Hadiths',
          style: TextStyle(fontFamily: 'PoppinsBold', fontSize: 17,
              color: isDarkTheme ? Colors.white : Colors.black),
        ),
        backgroundColor: isDarkTheme ? Colors.black26 : Colors.white,
      ),
      body: ValueListenableBuilder(
        valueListenable: _favoritesBox.listenable(),
        builder: (context, Box<FavoriteHadith> box, _) {
          if (box.isEmpty) {
            return Center(
              child: Text(
                'No Favorite Hadiths',
                style: TextStyle(fontSize: 18, fontFamily: 'Poppins', color: isDarkTheme ? Colors.white : Colors.black),
              ),
            );
          }

          return ListView.builder(
            itemCount: box.length,
            itemBuilder: (context, index) {
              final favoriteHadith = box.getAt(index);
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
                            favoriteHadith!.hadithNumber,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 13,
                              color: isDarkTheme ? Colors.white : Colors.black,
                            ),
                          ),
                        ),

                        IconButton(
                          icon: const Icon(
                            Icons.favorite,
                            color: Colors.red,
                          ),
                          onPressed: () =>
                              _removeFromFavorites(favoriteHadith.hadithNumber),
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy),
                          onPressed: () => _copyToClipboard(
                            favoriteHadith.body,
                            favoriteHadith.grade,
                            favoriteHadith.collectionName,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    if (favoriteHadith.chapterTitle.isNotEmpty)
                      Text(
                        favoriteHadith.collectionName.toUpperCase(),
                        style: TextStyle(
                          fontSize: 15,
                          fontFamily: 'PoppinsBold',
                          color: isDarkTheme ? Colors.white60 : Colors.black54,
                        ),
                      ),
                    const SizedBox(height: 5),
                      Text(
                        favoriteHadith.chapterTitle,
                        style: TextStyle(
                          fontSize: 17,
                          fontFamily: 'PoppinsBold',
                          color: isDarkTheme ? Colors.white : Colors.black,
                        ),
                      ),
                    const SizedBox(height: 5),
                    Text(
                      favoriteHadith.body,
                      style: TextStyle(
                        fontSize: 17,
                        fontFamily: 'Poppins',
                        color: isDarkTheme ? Colors.white : Colors.black,
                      ),
                      textAlign: TextAlign.justify,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Grade: ${favoriteHadith.grade}',
                      style:  TextStyle(
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
            },
          );
        },
      ),
    );
  }
}
