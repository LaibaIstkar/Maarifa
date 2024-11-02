
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as path;
import 'dart:typed_data';

import 'package:saver_gallery/saver_gallery.dart';


class FullScreenImagePage extends StatefulWidget {
  final List<String> images;
  final int initialIndex;

  const FullScreenImagePage({
    super.key,
    required this.images,
    required this.initialIndex,
  });

  @override
  FullScreenImagePageState createState() => FullScreenImagePageState();
}

class FullScreenImagePageState extends State<FullScreenImagePage> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  Future<void> _downloadImage(String imageUrl, BuildContext context) async {
    try {
      if (await Permission.storage.request().isGranted) {
        var response = await Dio().get(
          imageUrl,
          options: Options(responseType: ResponseType.bytes),
        );

        final imageBytes = Uint8List.fromList(response.data);
        final imageName = path.basename(imageUrl);

        final saveResult = await SaverGallery.saveImage(
          imageBytes,
          quality: 80,
          androidRelativePath: "Pictures/Maarifa",
          fileName: imageName,
          skipIfExists: false,
        );

        if(!context.mounted) return;
        if (saveResult.isSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: const Text('Image downloaded successfully.'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
          ));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: const Text('Failed to save image.'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
          ));
        }
      } else {
        if(!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text('Storage permission is required to download images.'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ));
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Failed to download image.'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Image ${_currentIndex + 1}',
          style: const TextStyle(fontSize: 17, fontFamily: 'PoppinsBold'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () => _downloadImage(widget.images[_currentIndex], context),
          ),
        ],
      ),
      backgroundColor: Colors.black,
      body: PageView.builder(
        itemCount: widget.images.length,
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        itemBuilder: (context, index) {
          return Center(
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: Image.network(
                widget.images[index],
                fit: BoxFit.contain,
                loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                  if (loadingProgress == null) {
                    return child;
                  }
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
                          : null,
                    ),
                  );
                },
                errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
                  return const Center(
                    child: Text(
                      'Error loading image',
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
