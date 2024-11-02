import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:maarifa/core/models/post_model/post.dart';
import 'package:maarifa/core/theme/app_colors.dart';
import 'package:maarifa/core/theme/theme_notifier.dart';
import 'package:maarifa/core/widgets/full_screen_image_widget.dart';
import 'package:maarifa/features/auth/view_model/auth_view_model.dart';
import 'package:maarifa/features/channels/logic/channels_controller.dart';
import 'package:maarifa/features/channels/logic/providers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';


class ChannelPosts extends ConsumerStatefulWidget {
  final String channelId;
  final String channelName;

  const ChannelPosts({super.key, required this.channelId, required this.channelName});

  @override
  ChannelPostsState createState() => ChannelPostsState();
}

class ChannelPostsState extends ConsumerState<ChannelPosts> {
  late Stream<List<Post>> _postsStream;
  final TextEditingController _contentEditingController = TextEditingController();
  late List<Post> _posts;

  late DateTime lastRead = DateTime.now();
  late ScrollController _scrollController;
  int unreadCount = 0;
  int lastReadIndex = 0;
  bool hasScrolled = false;
  final unreadCardKey = GlobalKey();
  bool showScrollDownButton = false;
  bool isAdminUser = false;



  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);

    _postsStream = ref.read(channelControllerProvider).getChannelPosts(widget.channelId);

    _fetchLastRead();

    checkIfUserIsCreator();
    _checkIfUserIsAdmin();

    _preCacheImages();

  }

  Future<void> _preCacheImages() async {
    final postsSnapshot = await _postsStream.first;
    for (Post post in postsSnapshot) {
      for (String imageUrl in post.images) {
        CachedNetworkImageProvider(imageUrl).resolve(const ImageConfiguration());
      }
    }
  }

  Future<void> _checkIfUserIsAdmin() async {
    isAdminUser = await ref.read(authViewModelProvider).isAdmin();
    setState(() {});
  }

  void _fetchLastRead() async {

    final fetchedLastRead = await getLastReadFromFirestore(widget.channelId);


    setState(() {
      lastRead = fetchedLastRead ?? DateTime.now();
    });
  }

  void _calculateUnreadCountAndFindLastReadIndex() {
    if (_posts.isNotEmpty) {
      setState(() {
        unreadCount = _posts.where((post) => post.timestamp != null && post.timestamp!.isAfter(lastRead)).length;
        lastReadIndex = _posts.indexWhere((post) => post.timestamp != null && post.timestamp!.isAfter(lastRead));
        if (lastReadIndex == -1) {
          lastReadIndex = _posts.length;
        } else {
          lastReadIndex = lastReadIndex - 1;
        }
      });
    }
  }



  void _scrollToUnreadOrBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients && !hasScrolled) {
        if (unreadCount > 0 && lastReadIndex < _posts.length) {
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);

          Future.delayed(const Duration(milliseconds: 200), () {
            _attemptScrollToUnreadCard();
          });
        } else {
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent * 2);
        }
      }
    });
  }

  void _attemptScrollToUnreadCard() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (unreadCardKey.currentContext != null) {
        Scrollable.ensureVisible(
          unreadCardKey.currentContext!,
          duration: const Duration(seconds: 1),
          curve: Curves.easeInOut,
        );
        hasScrolled = true;
      }
    });
  }


  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent) {
      setState(() {
        showScrollDownButton = false;
      });

      hasScrolled = true;
      Future.delayed(const Duration(seconds: 2), () {
        if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent) {
          _updateLastReadExplicitly();
        }
      });
    } else {
      setState(() {
        showScrollDownButton = true;
      });
    }
  }

  void _updateLastReadExplicitly() {
    if (_posts.isNotEmpty) {
      setState(() {
        lastRead = _posts.last.timestamp!;
        unreadCount = 0;
      });
      _updateLastReadInFirestore();
    }
  }


  void _updateLastReadInFirestore() async {
    final currentUser = ref.read(authViewModelProvider).getCurrentUser()?.uid;

    ref.invalidate(lastReadProvider(widget.channelId));

    await FirebaseFirestore.instance.collection('users').doc(currentUser).update({
      'joinedChannels.${widget.channelId}.lastRead': Timestamp.fromDate(lastRead),
    });
  }






  Future<DateTime?> getLastReadFromFirestore(String channelId) async {
    final currentUser = ref.read(authViewModelProvider).getCurrentUser()?.uid;

    DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(currentUser).get();
    if (userDoc.exists) {
      var data = userDoc.data() as Map<String, dynamic>;
      if (data['joinedChannels'] != null && data['joinedChannels'][channelId] != null) {
        return (data['joinedChannels'][channelId]['lastRead'] as Timestamp).toDate();
      }
    }
    return null;
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }



  Future<void> checkIfUserIsCreator() async {

    final currentUser = ref.read(authViewModelProvider).getCurrentUser()?.uid;
    await ref.read(channelControllerProvider).isChannelCreator(currentUser!, widget.channelId);
  }

  Future<String?> _showEmojiPicker(BuildContext context) async {
    List<String> emojis = ['❤️', '👍','😂', '😍', '😢', '😡', '🔥', '😎'];

    return await showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.5, end: 1.0).animate(
              CurvedAnimation(
                parent: AnimationController(
                  vsync: Navigator.of(context),
                  duration: const Duration(milliseconds: 300),
                ),
                curve: Curves.easeInOut, // Adjust curve for smoother effect
              ),
            ),
            child: Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.grey[90],
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Use a Wrap widget to avoid overflow
                  Wrap(
                    alignment: WrapAlignment.spaceEvenly, // Center align emojis
                    spacing: 15.0, // Space between emojis
                    runSpacing: 15.0, // Space between rows
                    children: emojis.map((emoji) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop(emoji); // Return selected emoji
                        },
                        child: Text(
                          emoji,
                          style: const TextStyle(fontSize: 50), // Emoji size
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildReactions(Map<String, String> reactions) {
    final Map<String, int> emojiCounts = {};

    reactions.forEach((userId, emoji) {
      emojiCounts[emoji] = (emojiCounts[emoji] ?? 0) + 1;
    });

    return emojiCounts.entries.map((entry) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: Row(
          children: [
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: entry.key),
                  TextSpan(
                    text: '${entry.value}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              style: const TextStyle(fontSize: 15),
            ),

          ],
        ),
      );
    }).toList();
  }

  Future<void> _deletePost(Post post, bool isDarkTheme, ChannelController channelController) async {
    // Show a confirmation dialog before deleting
    bool confirmDelete = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title:  Text("Delete Post", style : TextStyle(
          fontSize: 17,
          color: isDarkTheme ? Colors.white : Colors.black,
          fontFamily: 'PoppinsBold',
        )),
        content: Text("Are you sure you want to delete this post? This action cannot be undone.",
            style: TextStyle(
              fontSize: 13,
              color: isDarkTheme ? Colors.white : Colors.black,
              fontFamily: 'Poppins',
            )),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false), // Cancel
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true), // Confirm
            child: const Text(
              "Delete",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmDelete) {
      await channelController.deletePost(widget.channelId, post.id, post.images);
    }
  }

  Future<void> _editPost(Post post, bool isDarkTheme, ChannelController channelController) async {
    _contentEditingController.text = post.content;

    bool confirmEdit = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Edit Post", style: TextStyle(
          fontSize: 17,
          color: isDarkTheme ? Colors.white : Colors.black,
          fontFamily: 'PoppinsBold',
        )),
        content: TextField(
          controller: _contentEditingController,
          style: TextStyle(
            fontSize: 13,
            color: isDarkTheme ? Colors.white : Colors.black,
            fontFamily: 'Poppins',
          ),
          maxLines: 5,
          decoration: InputDecoration(
              hintText: 'Update your post content...',
              hintStyle: TextStyle(
                fontSize: 13,
                color: isDarkTheme ? Colors.white : Colors.black,
                fontFamily: 'Poppins',
              )
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text("Save"),
          ),
        ],
      ),
    );

    if (confirmEdit) {
      await channelController.updatePost(widget.channelId, post.id, _contentEditingController.text);
    }

    _contentEditingController.clear();
  }

  void _showFullImage(int initialIndexm, Post post) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FullScreenImagePage(
          images: post.images,
          initialIndex: initialIndexm,
        ),
      ),
    );
  }


  Future<void> _reportPostDialog(BuildContext context, String postId, String channelId, String channelName, ChannelController channelController) async {
    TextEditingController reportController = TextEditingController();
    bool isLoading = false;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Report Post", style: TextStyle(fontFamily: 'PoppinsBold', fontSize: 17),),
          content: TextField(
            controller: reportController,
            style: const TextStyle(fontFamily: 'Poppins', fontSize: 14),
            maxLength: 100,
            maxLines: null,
            decoration: const InputDecoration(hintText: "Enter reason for reporting"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel", style: TextStyle(fontFamily: 'PoppinsBold'),),
            ),
            TextButton(
              onPressed: isLoading ? null : () async {
                if (reportController.text.isNotEmpty) {
                  isLoading = true;
                  channelController.reportPost(channelId, channelName, postId, reportController.text, context);

                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text("Reported successfully."),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ));
                }
              },
              child: const Text("Report", style: TextStyle(fontFamily: 'PoppinsBold', color: Colors.red),),
            ),
          ],
        );
      },
    );
  }




  @override
  Widget build(BuildContext context) {
    final isDarkTheme = ref.watch(themeNotifierProvider);
    final currentUser = ref.read(authViewModelProvider).getCurrentUser()?.uid;
    final channelController = ref.watch(channelControllerProvider);
    final bool isCreatorCached = ChannelController.getCachedIsCreator(widget.channelId);

    return Stack(
      children: [ Row(
        children: [
          Expanded(
            child: StreamBuilder<List<Post>>(
              stream: _postsStream, // Use the cached stream
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(height: 10),
                        Text(
                          'Loading...',
                          style: TextStyle(
                            fontSize: MediaQuery.of(context).textScaler.scale(17),
                            color: isDarkTheme ? Colors.white : Colors.black,
                            fontFamily: 'PoppinsBold',
                          ),
                        ),
                      ],
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error loading posts',
                      style: TextStyle(
                        fontSize: MediaQuery.of(context).textScaler.scale(17),
                        color: isDarkTheme ? Colors.white : Colors.black,
                        fontFamily: 'PoppinsBold',
                      ),
                    ),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Text(
                      'No posts yet',
                      style: TextStyle(
                        fontSize: MediaQuery.of(context).textScaler.scale(17),
                        color: isDarkTheme ? Colors.white : Colors.black,
                        fontFamily: 'PoppinsBold',
                      ),
                    ),
                  );
                }

                _posts = snapshot.data!;

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _calculateUnreadCountAndFindLastReadIndex();
                  WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToUnreadOrBottom());
                });


                return ListView.builder(
                  controller: _scrollController,
                  itemCount: _posts.length + (unreadCount > 0 ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == lastReadIndex + 1 && unreadCount > 0) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 20.0),
                        child: Card(
                          key: unreadCardKey,
                          color: Colors.black,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 10.0),
                            child: Center(
                              child: Text(
                                '$unreadCount Unread Messages',
                                style: TextStyle(
                                  fontSize: MediaQuery.of(context).textScaler.scale(13),
                                  fontFamily: 'Poppins',
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }

                    final postIndex = (index > lastReadIndex + 1) ? index - 1 : index;
                    final post = _posts[postIndex];

                    String formattedDate = post.timestamp != null
                        ? DateFormat('d MMM, yyyy, h:mm a').format(post.timestamp!)
                        : 'Date';
                    var isDeletionWarning = post.isDeletionWarning;
                    isDeletionWarning ??= false;

                    return GestureDetector(
                      onTap: () async {
                        String? selectedEmoji = await _showEmojiPicker(context);
                        if (selectedEmoji != null) {
                          await ref.read(channelControllerProvider).reactToPost(post.id, currentUser, selectedEmoji);
                        }
                      },
                      onLongPress: isDeletionWarning
                          ? null
                          : () async {
                        showModalBottomSheet(
                          context: context,
                          builder: (context) {
                            return ListView(
                              shrinkWrap: true,
                              children: _getBottomSheetOptions(post, isCreatorCached, channelController, context, isDarkTheme),
                            );
                          },
                        );
                      },
                      child: _buildPostCard(post, isDeletionWarning, formattedDate, isDarkTheme),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
        if (showScrollDownButton)
          Positioned(
            bottom: 20,
            left: 20,
            child: FloatingActionButton(
              onPressed: _scrollToBottom,
              backgroundColor: AppColors.secondaryColorSilver,
              child: const Icon(Icons.arrow_downward),
            ),
          ),
      ],

    );
  }

  List<Widget> _getBottomSheetOptions(Post post, bool isCreatorCached, ChannelController channelController, BuildContext context, bool isDarkTheme) {
    List<Widget> options = [];

    if (isAdminUser) {
      options.add(
        ListTile(
          title: const Text("Delete Post"),
          onTap: () async {
            Navigator.pop(context);
            await _deletePost(post, isDarkTheme, channelController);
          },
        ),
      );
      options.add(
        ListTile(
          title: const Text("Copy Content"),
          onTap: () {
            Clipboard.setData(ClipboardData(text: post.content));
            Navigator.pop(context);
          },
        ),
      );
      options.add(
        ListTile(
          title: const Text("Report Post"),
          onTap: () {
            Navigator.pop(context);
            _reportPostDialog(context, post.id, widget.channelId, widget.channelName, channelController);
          },
        ),
      );
    } else if (isCreatorCached) {
      options.add(
        ListTile(
          title: const Text("Edit Post"),
          onTap: () async {
            Navigator.pop(context);
            await _editPost(post, isDarkTheme, channelController);
          },
        ),
      );
      options.add(
        ListTile(
          title: const Text("Delete Post"),
          onTap: () async {
            Navigator.pop(context);
            await _deletePost(post, isDarkTheme, channelController);
          },
        ),
      );
    } else {
      // Normal users
      options.add(
        ListTile(
          title: const Text("Copy Content"),
          onTap: () {
            Clipboard.setData(ClipboardData(text: post.content));
            Navigator.pop(context);
          },
        ),
      );
      options.add(
        ListTile(
          title: const Text("Report Post"),
          onTap: () {
            Navigator.pop(context);
            _reportPostDialog(context, post.id, widget.channelId, widget.channelName, channelController);
          },
        ),
      );
    }

    return options;
  }


  Widget _buildPostContent(Post post, bool isDeletionWarning, bool isDarkTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (post.images.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: post.images.length == 1
                ? GestureDetector(
              onTap: () => _showFullImage(0, post),
              child: CachedNetworkImage(
                imageUrl: post.images[0],
                placeholder: (context, url) => Shimmer(
                    gradient: LinearGradient(
                      colors: [
                        Colors.grey.shade300,
                        Colors.grey.shade200,
                        Colors.grey.shade300,
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    child: Container(
                      height: 200,
                      width: double.infinity,
                      color: Colors.grey,
                    )),
                fit: BoxFit.cover,
                width: double.infinity,
                height: 200,
              ),
            )
                : _buildImageGrid(post.images, post),
          ),
        if (post.content.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              post.content,
              style: TextStyle(
                fontSize: MediaQuery.of(context).textScaler.scale(15),
                color: isDarkTheme ? Colors.white : Colors.black,
                fontFamily: isDeletionWarning ? 'PoppinsBold' : 'Poppins',
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildImageGrid(List<String> images, Post post) {
    return Column(
      children: [
        GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: MediaQuery.of(context).size.aspectRatio * 2,
            crossAxisSpacing: 4,
            mainAxisSpacing: 4,
          ),
          itemCount: images.length > 2 ? 2 : images.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () => _showFullImage(index, post),
              child: CachedNetworkImage(
                imageUrl: images[index],
                placeholder: (context, url) => Shimmer(
                    gradient: LinearGradient(
                  colors: [
                    Colors.grey.shade300,
                    Colors.grey.shade200,
                    Colors.grey.shade300,
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                child: Container(
                  height: 200,
                  width: double.infinity,
                  color: Colors.grey,
                )),
                fit: BoxFit.cover,
                width: MediaQuery.of(context).size.width * 0.45,
              ),
            );
          },
        ),
      ],
    );
  }




  Widget _buildPostCard(Post post, bool isDeletionWarning, String formattedDate, bool isDarkTheme) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: MediaQuery.of(context).size.height * 0.01,
        horizontal: MediaQuery.of(context).size.width * 0.03,
      ),
      child: Card(
        color: isDeletionWarning ? Colors.red[200] : (isDarkTheme ? Colors.grey[900] : Colors.grey[290]),
        child: Padding(
          padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.03),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                formattedDate,
                style: TextStyle(
                  fontSize: MediaQuery.of(context).textScaler.scale(12),
                  color: isDeletionWarning ? Colors.black : Colors.grey[700],
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 4),
              _buildPostContent(post, isDeletionWarning, isDarkTheme),
              if (post.reactions.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Row(
                    children: _buildReactions(post.reactions),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

}




