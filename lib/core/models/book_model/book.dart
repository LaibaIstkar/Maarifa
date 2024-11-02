import 'package:hive/hive.dart';

part 'book.g.dart';

@HiveType(typeId: 5)
class Book extends HiveObject {
  @HiveField(0)
  final String arabicName;

  @HiveField(1)
  final String englishName;

  @HiveField(2)
  final String author;

  @HiveField(3)
  final String description;

  @HiveField(4)
  final String pdfUrl;

  @HiveField(5)
  final String category;

  Book({
    required this.arabicName,
    required this.englishName,
    required this.author,
    required this.description,
    required this.pdfUrl,
    required this.category,
  });

  // Factory constructor for creating Book instance from Firestore data
  factory Book.fromFirestore(Map<String, dynamic> data, String category) {
    return Book(
      category: category,
      arabicName: Book.extractArabicName(data['fileName']),
      englishName: Book.extractEnglishName(data['fileName']),
      author: Book.extractAuthor(data['fileName']),
      description: data['description'],
      pdfUrl: data['pdfUrl'], // This will be filled in the helper function below
    );
  }

  // Static helper methods
  // Extract Arabic name from the fileName within parentheses (if present)
  static String extractArabicName(String fileName) {
    final match = RegExp(r'\((.*?)\)').firstMatch(fileName);
    return match != null ? match.group(1)!.trim() : '';
  }

// Extract English name, which is between the closing parenthesis and the hyphen
  static String extractEnglishName(String fileName) {
    final regex = RegExp(r'\)\s*(.*?)\s*-\s*');
    final match = regex.firstMatch(fileName);
    return match != null ? match.group(1)!.trim() : '';
  }

// Extract author’s name, which appears after the hyphen and before the file extension
  static String extractAuthor(String fileName) {
    final regex = RegExp(r'-\s*(.*?)\.pdf$');
    final match = regex.firstMatch(fileName);
    return match != null ? match.group(1)!.trim() : '';
  }

}
