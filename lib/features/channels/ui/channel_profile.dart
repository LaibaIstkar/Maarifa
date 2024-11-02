import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maarifa/core/models/channel_model/channel.dart';
import 'package:maarifa/core/theme/app_colors.dart';
import 'package:maarifa/core/theme/app_colors_dark.dart';
import 'package:maarifa/core/theme/theme_notifier.dart';
import 'package:maarifa/core/widgets/full_screen_image_widget.dart';

class ChannelProfile extends ConsumerStatefulWidget {
  final Channel channel;

  const ChannelProfile({
    required this.channel,
    super.key,
  });

  @override
  ChannelProfileState createState() => ChannelProfileState();
}

class ChannelProfileState extends ConsumerState<ChannelProfile> {
  Future<int> _getMemberCount() async {
    final membersSnapshot = await FirebaseFirestore.instance
        .collection('channels')
        .doc(widget.channel.id)
        .collection('members')
        .get();
    return membersSnapshot.docs.length;
  }

  Future<List<String>> _getChannelImages() async {
    final postsSnapshot = await FirebaseFirestore.instance
        .collection('posts')
        .where('channelId', isEqualTo: widget.channel.id)
        .get();

    final List<String> imageUrls = [];

    for (var doc in postsSnapshot.docs) {
      if (doc.data().containsKey('images')) {
        final imagesData = doc.get('images');
        if (imagesData != null && imagesData is List<dynamic>) {
          final List<String> images = imagesData.cast<String>();
          imageUrls.addAll(images);
        }
      }
    }

    return imageUrls;
  }

  void _showFullImage(int initialIndex, List<String> imageUrls) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FullScreenImagePage(
          images: imageUrls,
          initialIndex: initialIndex,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = ref.watch(themeNotifierProvider);

    return Scaffold(
      body: FutureBuilder<int>(
        future: _getMemberCount(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final memberCount = snapshot.data!;

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 200.0,
                pinned: true,
                flexibleSpace: LayoutBuilder(
                  builder: (context, constraints) {
                    final isCollapsed = constraints.maxHeight <= kToolbarHeight;
                    final imageSize = isCollapsed ? 40.0 : 100.0;

                    return FlexibleSpaceBar(
                      title: Row(
                        children: [
                          if (isCollapsed)
                            CircleAvatar(
                              backgroundImage: NetworkImage(widget.channel.coverPhoto),
                              radius: 20,
                            ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              widget.channel.title,
                              style: TextStyle(
                                fontSize: 16,
                                fontFamily: 'PoppinsBold',
                                color: isDarkTheme ? Colors.white : Colors.black,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      background: Image.network(
                        widget.channel.coverPhoto,
                        fit: BoxFit.cover,
                      ),
                    );
                  },
                ),
                leading: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDarkTheme ? AppColorsDark.cardBackground : AppColors.primaryColorPlatinum,
                      ),
                    child:  IconButton(
                      icon: Icon(Icons.arrow_back, color: isDarkTheme ? Colors.white : Colors.black),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      Text(
                        '$memberCount Followers',
                        style: TextStyle(
                          fontSize: 12,
                          fontFamily: 'Poppins',
                          color: isDarkTheme ? Colors.white54 : Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Description',
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: 'PoppinsBold',
                          color: isDarkTheme ? AppColorsDark.purpleColor : AppColors.purpleColor,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        widget.channel.description,
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'Poppins',
                          color: isDarkTheme ? Colors.white : Colors.black,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Purpose',
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: 'PoppinsBold',
                          color: isDarkTheme ? AppColorsDark.purpleColor : AppColors.purpleColor,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        widget.channel.purpose,
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'Poppins',
                          color: isDarkTheme ? Colors.white : Colors.black,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Images',
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: 'PoppinsBold',
                          color: isDarkTheme ? Colors.white : Colors.black,
                        ),
                      ),
                      const SizedBox(height: 10),
                      FutureBuilder<List<String>>(
                        future: _getChannelImages(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const Center(child: CircularProgressIndicator());
                          }

                          final imageUrls = snapshot.data!;
                          if (imageUrls.isEmpty) {
                            return const Text('No images available.');
                          }

                          return GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                            ),
                            itemCount: imageUrls.length,
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () {
                                  _showFullImage(index, imageUrls);
                                },
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    imageUrls[index],
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
