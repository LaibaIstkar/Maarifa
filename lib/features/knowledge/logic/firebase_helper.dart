import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:maarifa/core/models/book_model/book.dart';
import 'package:path_provider/path_provider.dart';


class FirebaseHelper {
  static Future<List<Book>> fetchBooksByCategory(String category) async {
    final firestore = FirebaseFirestore.instance;
    final storage = FirebaseStorage.instance;

    // Step 1: Fetch the category document
    final categoryDoc = await firestore.collection('books').doc(category).get();
    if (!categoryDoc.exists) {
      throw Exception("Category document '$category' does not exist.");
    }
    final categoryFields = categoryDoc.data()!;

    print(categoryFields.keys);

    final List<Book> books = [];

    // Step 2: Fetch all files in the specified category folder in Storage
    final storageRef = storage.ref('books/$category');
    final listResult = await storageRef.listAll();

    // Step 3: Iterate over each item (PDF file)
    for (var item in listResult.items) {
      final pdfName = item.name;

      // Extract metadata from the file name
      final arabicName = Book.extractArabicName(pdfName);
      final englishName = Book.extractEnglishName(pdfName);
      final author = Book.extractAuthor(pdfName);

      // Match with Firestore fields
      if (categoryFields.containsKey(englishName)) {
        print(englishName);

        final description = categoryFields[englishName];

        print(description);

        // Fetch PDF download URL
        final pdfUrl = await item.getDownloadURL();

        // Create a Book instance and add it to the list
        final book = Book(
          category: category,
          arabicName: arabicName,
          englishName: englishName,
          author: author,
          description: description,
          pdfUrl: pdfUrl,
        );
        books.add(book);
      } else{
        print('doesnot');
        print(author);
      }
    }
    return books;
  }
  static Future<Uint8List> fetchPdf(String url) async {
    // Get the local directory
    final Directory appDocDir = await getApplicationDocumentsDirectory();
    final String fileName = url.split('/').last;
    final File localFile = File('${appDocDir.path}/$fileName');

    // Check if the file exists locally
    if (await localFile.exists()) {
      return await localFile.readAsBytes(); // Read from local cache
    }

    // If not, download and save to local cache
    final storageRef = FirebaseStorage.instance.refFromURL(url);
    final data = await storageRef.getData();
    await localFile.writeAsBytes(data!); // Save to local cache
    return data;
  }

}


