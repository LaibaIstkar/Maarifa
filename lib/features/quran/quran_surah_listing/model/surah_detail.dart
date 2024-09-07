import 'package:hive/hive.dart';
import 'ayah.dart'; // Assuming Ayah is defined in a separate file

part 'surah_detail.g.dart';

@HiveType(typeId: 2)
class SurahDetail extends HiveObject {
  @HiveField(0)
  final int number;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String englishName;

  @HiveField(3)
  final String englishNameTranslation;

  @HiveField(4)
  final String revelationType;

  @HiveField(5)
  final int numberOfAyahs;

  @HiveField(6)
  final List<Ayah> ayahs;

  @HiveField(7)
  final List<Ayah> translations;

  SurahDetail({
    required this.number,
    required this.name,
    required this.englishName,
    required this.englishNameTranslation,
    required this.revelationType,
    required this.numberOfAyahs,
    required this.ayahs,
    required this.translations,
  });

  factory SurahDetail.fromJson(Map<String, dynamic> arabicJson, Map<String, dynamic> translationJson) {
    List<Ayah> arabicAyahs = (arabicJson['ayahs'] as List).map((e) => Ayah.fromJson(e)).toList();
    List<Ayah> translatedAyahs = (translationJson['ayahs'] as List).map((e) => Ayah.fromJson(e)).toList();





    return SurahDetail(
      number: arabicJson['number'],
      name: arabicJson['name'],
      englishName: arabicJson['englishName'],
      englishNameTranslation: arabicJson['englishNameTranslation'],
      revelationType: arabicJson['revelationType'],
      numberOfAyahs: arabicJson['numberOfAyahs'],
      ayahs: arabicAyahs,
      translations: translatedAyahs,
    );
  }
}







