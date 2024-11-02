import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maarifa/core/theme/theme_notifier.dart';
import 'package:maarifa/features/knowledge/logic/firebase_helper.dart';
import 'package:maarifa/features/knowledge/view/widgets/book_list_page.dart';
import 'package:hive/hive.dart';
import 'package:maarifa/core/models/book_model/book.dart';


class KnowledgePage extends ConsumerStatefulWidget {
  const KnowledgePage({super.key});

  @override
  ConsumerState<KnowledgePage> createState() => _KnowledgePageState();
}

class _KnowledgePageState extends ConsumerState<KnowledgePage> {
  final List<String> titles = ['Aqeedah', 'Hadith', 'Tafseer', 'Seerah', 'Knowledge', 'Shariah'];

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = ref.watch(themeNotifierProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Knowledge", style: TextStyle(fontSize: 17, fontFamily: 'PoppinsBold')),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: titles.map((title) => buildCategoryCard(context, title, isDarkTheme)).toList(),
        ),
      ),
    );
  }

  Widget buildCategoryCard(BuildContext context, String title, bool isDarkTheme) {
    return GestureDetector(
      onTap: () async => fetchBooks(context, title.toLowerCase(), title),
      child: Card(
        color: isDarkTheme ? Colors.grey[850] : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Center(child: Text(title, style: const TextStyle(fontSize: 18, fontFamily: 'PoppinsBold'))),
        ),
      ),
    );
  }

  Future<void> fetchBooks(BuildContext context, String category, String title) async {
    final cachedBox = await Hive.openBox<Book>('booksCache');
    if (cachedBox.isNotEmpty) {
      final cachedBooks = cachedBox.values.where((book) => book.category == category).toList();
      if (cachedBooks.isNotEmpty) {
        displayBooks(context, cachedBooks);
        return;
      }
    }

    // Fetch from Firestore if not cached
    final books = await FirebaseHelper.fetchBooksByCategory(category);
    for (final book in books) {
      await cachedBox.add(book);
    }
    displayBooks(context, books);
  }

  void displayBooks(BuildContext context, List<Book> books) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => BookListPage(books: books)));
  }
}