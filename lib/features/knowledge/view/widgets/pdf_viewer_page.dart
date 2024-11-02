import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';


class PdfViewerPage extends StatelessWidget {
  final String pdfUrl;

  const PdfViewerPage({super.key, required this.pdfUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Read Book")),
      body: PdfView(controller: PdfController(document: PdfDocument.openAsset(pdfUrl))),
    );
  }
}
