import 'package:hive/hive.dart';

part 'ayah.g.dart';


@HiveType(typeId: 3)
class Ayah extends HiveObject {
  @HiveField(0)
  final int number;

  @HiveField(1)
  final String text;

  @HiveField(2)
  final int numberInSurah;

  Ayah({
    required this.number,
    required this.text,
    required this.numberInSurah,
  });

  factory Ayah.fromJson(Map<String, dynamic> json) {
    return Ayah(
      number: json['number'],
      text: json['text'],
      numberInSurah: json['numberInSurah'],
    );
  }
}
