import 'package:hive/hive.dart';

part 'favoriteayah.g.dart';

@HiveType(typeId: 1)
class FavoriteAyah extends HiveObject {
  @HiveField(0)
  final String arabicText;

  @HiveField(1)
  final String englishText;

  @HiveField(2)
  final String surahName;

  @HiveField(3)
  final String revelationPlace;

  @HiveField(4)
  final int ayahNumber;

  @HiveField(5)
  final int ayahNumberInSurah;

  FavoriteAyah({
    required this.arabicText,
    required this.englishText,
    required this.surahName,
    required this.revelationPlace,
    required this.ayahNumber,
    required this.ayahNumberInSurah,
  });
}
