import 'package:hive/hive.dart';

part 'favorite_hadith.g.dart'; // Generated file

@HiveType(typeId: 4)
class FavoriteHadith extends HiveObject {
  @HiveField(0)
  final String hadithNumber;

  @HiveField(1)
  final String body;

  @HiveField(2)
  final String chapterTitle;

  @HiveField(3)
  final String grade;

  @HiveField(4)
  final String collectionName;

  FavoriteHadith({
    required this.hadithNumber,
    required this.body,
    required this.chapterTitle,
    required this.grade,
    required this.collectionName,
  });
}
