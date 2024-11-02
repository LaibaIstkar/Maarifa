import 'package:hive/hive.dart';



part 'surah.g.dart';

@HiveType(typeId: 0)
class Surah extends HiveObject {
  @HiveField(0)
  final int number;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String englishName;

  @HiveField(3)
  final String englishNameTranslation;

  @HiveField(4)
  final int numberOfAyahs;

  @HiveField(5)
  final String revelationType;

  Surah({
    required this.number,
    required this.name,
    required this.englishName,
    required this.englishNameTranslation,
    required this.numberOfAyahs,
    required this.revelationType,
  });

  factory Surah.fromJson(Map<String, dynamic> json) {
    return Surah(
      number: json['number'],
      name: json['name'],
      englishName: json['englishName'],
      englishNameTranslation: json['englishNameTranslation'],
      numberOfAyahs: json['numberOfAyahs'],
      revelationType: json['revelationType'],
    );
  }
}
