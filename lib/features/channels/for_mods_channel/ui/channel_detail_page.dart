import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:maarifa/core/models/channel_model/channel.dart';
import 'package:maarifa/core/theme/content_provider.dart';
import 'package:maarifa/core/theme/send_button_notifier.dart';
import 'package:maarifa/core/theme/theme_notifier.dart';
import 'package:maarifa/core/widgets/channel_cover_photo.dart';
import 'package:maarifa/features/channels/for_mods_channel/provider/channel_deletion_status_provider.dart';
import 'package:maarifa/features/channels/for_mods_channel/ui/channel_posts.dart';
import 'package:maarifa/features/channels/logic/channels_controller.dart';
import 'package:maarifa/features/channels/ui/channel_profile.dart';

class ChannelDetailPage extends ConsumerStatefulWidget {
  final Channel channel;

  const ChannelDetailPage({required this.channel, super.key});

  @override
  ChannelDetailPageState createState() => ChannelDetailPageState();
}


class ChannelDetailPageState extends ConsumerState<ChannelDetailPage> {


  String content = '';

  final TextEditingController _contentController = TextEditingController();
  final List<File?> _selectedImages = [];
  final isLoadingProvider = StateProvider<bool>((ref) => false);





  Future<void> _sendPost(bool isSendEnabled) async {

    final channelController = ref.read(channelControllerProvider);

    if (!isSendEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Message must have at least 50 characters or one image'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
      );
      return;
    }

    if (_selectedImages.length > 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Only 5 images allowed in one post'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
      );
      return;
    }


    ref.read(isLoadingProvider.notifier).state = true;

    try{
      List<String> imageUrls = [];
      for (var selectedImage in _selectedImages) {
        if (selectedImage != null) {
          final storageRef = FirebaseStorage.instance.ref().child(
              'channel_images/${widget.channel.id}/${DateTime.now().millisecondsSinceEpoch}');
          final uploadTask = await storageRef.putFile(selectedImage);
          String imageUrl = await uploadTask.ref.getDownloadURL();
          imageUrls.add(imageUrl);
        }
      }

      await channelController.postContent(
        widget.channel.id,
        _contentController.text,
        imageUrls: imageUrls,
      );

      _contentController.clear();
      setState(() {
        _selectedImages.clear();
      });
    } finally {
      ref.read(isLoadingProvider.notifier).state = false;
      ref.read(sendButtonProvider.notifier).updateState(null, _selectedImages);

    }

  }

  Future<void> _pickImage() async {
    final pickedFiles = await ImagePicker().pickMultiImage();
    setState(() {
      if (_selectedImages.length + pickedFiles.length <= 5) {
        _selectedImages.addAll(pickedFiles.map((file) => File(file.path)));
        ref.refresh(sendButtonProvider.notifier).updateState(null, _selectedImages);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: const Text('Only 5 images allowed in one post'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),),
        );
      }
    });
    }


  Future<void> _deleteChannelDialoge(BuildContext context, String channelId, String channelName, ChannelController channelController) async {
    bool isLoading = false;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Delete Channel", style: TextStyle(fontFamily: 'PoppinsBold', fontSize: 17, color: Colors.red)),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("This action can not be undone ! You will loose writing access to your channel, and channel will be deleted in 3 days."),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel", style: TextStyle(fontFamily: 'PoppinsBold')),
            ),
            TextButton(
              onPressed: isLoading ? null : () async {
                isLoading = true;
                  // Step 1: Add a red-colored post announcing the deletion
                  await channelController.scheduleChannelDeletion(channelId);

                  ref.invalidate(channelDeletionStatusProvider(channelId));


                  if(!context.mounted) return;

                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text("Channel marked for deletion in 3 days. "),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                    ),
                  );

              },
              child: const Text("Delete", style: TextStyle(fontFamily: 'PoppinsBold', color: Colors.red)),
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {

    final isDarkTheme = ref.watch(themeNotifierProvider);
    final channelController = ref.watch(channelControllerProvider);
    final isSendEnabled = ref.watch(sendButtonProvider);

    final asyncDeletionStatus = ref.watch(channelDeletionStatusProvider(widget.channel.id));

    final isLoading = ref.watch(isLoadingProvider);




    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChannelProfile(channel: widget.channel),
              ),
            );
          },
          child: Row(
            children: [
              ChannelCoverPhoto(
                coverPhotoUrl: widget.channel.coverPhoto,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChannelProfile(channel: widget.channel),
                    ),
                  );
                },
              ),
              const SizedBox(width: 10,),
              Text(
                widget.channel.title,
                style: TextStyle(
                  fontSize: MediaQuery.of(context).textScaler.scale(17),
                  color: isDarkTheme ? Colors.white : Colors.black,
                  fontFamily: 'PoppinsBold',
                ),
              ),
            ]
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDarkTheme ? Colors.white : Colors.black),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        backgroundColor: isDarkTheme ? Colors.black26 : Colors.white,
        actions: [
          asyncDeletionStatus.when(
              data: (isDeletionScheduled) {
                if(!isDeletionScheduled) {
                  return PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'Delete Channel') {
                        _deleteChannelDialoge(context, widget.channel.id, widget.channel.title, channelController);}
                    },
                    itemBuilder: (context) {
                      return [
                        const PopupMenuItem(value: 'Delete Channel', child: Text('Delete Channel')),
                      ];
                    },
                  );
                } else {
                  return const SizedBox.shrink();
                }
              },
              loading: () => const LinearProgressIndicator(),
              error: (error, stack) => Text('Error: $error'),)
        ],
      ),
      body: Column(
      children: [
        Expanded(
            child: ChannelPosts(channelId: widget.channel.id, channelName:  widget.channel.title),
        ),

        asyncDeletionStatus.when(
          data: (isDeletionScheduled) {
            if (!isDeletionScheduled) {
              return Column(
                children: [
                  if (isLoading) const LinearProgressIndicator(),
                  if (_selectedImages.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Wrap(
                        spacing: 8,
                        children: _selectedImages.map((image) {
                          return Stack(
                            alignment: Alignment.topRight,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.grey),
                                  ),
                                  child: Image.file(
                                    image!,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                    Icons.close, size: 20, color: Colors.white
                                ),
                                onPressed: () {
                                  setState(() {
                                    _selectedImages.remove(image);
                                    ref.refresh(sendButtonProvider.notifier).updateState(null, _selectedImages);
                                  });
                                },
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.grey[300],
                            ),
                            child: const Icon(Icons.photo, size: 24, color: Colors.black),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey, width: 2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: TextField(
                              controller: _contentController,
                              maxLines: MediaQuery.of(context).size.height > 600 ? 4 : 2,
                              minLines: 1,
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.02),
                                hintText: 'Write a message...',
                                border: InputBorder.none,
                                hintStyle: TextStyle(
                                  fontSize: MediaQuery.of(context).textScaler.scale(17),
                                  color: isDarkTheme ? Colors.white : Colors.black,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                              style: TextStyle(
                                fontSize: MediaQuery.of(context).textScaler.scale(17),
                                color: isDarkTheme ? Colors.white : Colors.black,
                                fontFamily: 'Poppins',
                              ),
                              onChanged: (text) {
                                ref.read(contentProvider.notifier).updateContent(text);
                                ref.read(sendButtonProvider.notifier).updateState(text, _selectedImages);
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: Icon(
                            Icons.send,
                            color: isLoading ? Colors.grey : (isSendEnabled ? Colors.blue : Colors.grey),
                          ),
                          onPressed: isLoading ? null : () {
                            _sendPost(isSendEnabled);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              );
            } else {
              return const SizedBox.shrink();
            }
          },
          loading: () => const LinearProgressIndicator(),
            error: (error, stack) => Text('Error: $error'),)
      ],
            ),
      );
  }


}








