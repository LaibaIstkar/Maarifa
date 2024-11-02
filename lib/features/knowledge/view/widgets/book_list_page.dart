import 'package:flutter/material.dart';
import 'package:maarifa/core/models/book_model/book.dart';
import 'package:maarifa/features/knowledge/logic/firebase_helper.dart';
import 'package:maarifa/features/knowledge/view/widgets/pdf_viewer_page.dart';
import 'package:path/path.dart';
import 'package:pdfx/pdfx.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class BookListPage extends StatelessWidget {
  final List<Book> books;

  const BookListPage({super.key, required this.books});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Books")),
      body: ListView.builder(
        itemCount: books.length,
        itemBuilder: (context, index) {
          final book = books[index];
          return buildBookCard(book);
        },
      ),
    );
  }

  Widget buildBookCard(Book book) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.all(10),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display cover image from assets
            Image.asset(
              'assets/books/${book.englishName}.jpg',
              fit: BoxFit.cover,
              height: 200,
              width: double.infinity,
            ),
            const SizedBox(height: 8),
            // Arabic Title
            Text(
              book.arabicName,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            // English Title
            Text(
              book.englishName,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            // Description
            Text(
              book.description,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 10),
            // "Read" button to open PDF
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () => openPdf(context as BuildContext, book.pdfUrl),
                child: const Text('Read'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void openPdf(BuildContext context, String pdfUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PdfViewerPage(pdfUrl: pdfUrl),
      ),
    );
  }
}