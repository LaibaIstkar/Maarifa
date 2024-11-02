import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maarifa/core/models/channel_model/channel.dart';
import 'package:maarifa/core/theme/theme_notifier.dart';
import 'package:maarifa/core/widgets/channel_cover_photo.dart';
import 'package:maarifa/features/auth/view_model/auth_view_model.dart';
import 'package:maarifa/features/channels/for_mods_channel/ui/channel_posts.dart';
import 'package:maarifa/features/channels/logic/channels_controller.dart';
import 'package:maarifa/features/channels/ui/channel_profile.dart';


class UserChannelDetailPage extends ConsumerStatefulWidget {
  final Channel channel;

  const UserChannelDetailPage({super.key, required this.channel});

  @override
  ConsumerState<UserChannelDetailPage> createState() => _UserChannelDetailPageState();
}

class _UserChannelDetailPageState extends ConsumerState<UserChannelDetailPage> {
  final bool _isLoading = false;

  Future<void> _reportChannelDialog(BuildContext context, String channelId, String channelName, ChannelController channelController) async {
    TextEditingController reportController = TextEditingController();
    bool isLoading = false;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Report Channel", style: TextStyle(fontFamily: 'PoppinsBold', fontSize: 17)),
          content: TextField(
            controller: reportController,
            maxLength: 100,
            maxLines: null,
            style: const TextStyle(fontFamily: 'Poppins', fontSize: 14),
            decoration: const InputDecoration(hintText: "Enter reason for reporting"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel", style: TextStyle(fontFamily: 'PoppinsBold')),
            ),
            TextButton(
              onPressed: isLoading ? null : () async {
                if (reportController.text.isNotEmpty) {
                  isLoading = true;
                  // Store the report in Firestore
                  channelController.reportChannel(channelId, channelName, reportController.text, context);

                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: const Text("Reported successfully."),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),));
                }
              },
              child: const Text("Report", style: TextStyle(fontFamily: 'PoppinsBold', color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _leaveChannelDialog(BuildContext context, String channelId, String userId, ChannelController channelController) async {
    bool isLoading = false;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Leave Channel", style: TextStyle(fontFamily: 'PoppinsBold', fontSize: 17)),
          content: const Text(
            "Are you sure you want to leave this channel ?",
            style: TextStyle(fontFamily: 'Poppins', fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel", style: TextStyle(fontFamily: 'PoppinsBold')),
            ),
            TextButton(
              onPressed: isLoading ? null : () async {
                  isLoading = true;
                  // Store the report in Firestore
                  channelController.leaveChannel(userId ,channelId);

                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: const Text("Successfully left the Channel."),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),));

              },
              child: const Text("Leave", style: TextStyle(fontFamily: 'PoppinsBold', color: Colors.red)),
            ),
          ],
        );
      },
    );
  }



  @override
  Widget build(BuildContext context) {
    final isDarkTheme = ref.watch(themeNotifierProvider);
    final authView = ref.watch(authViewModelProvider);
    final channelController = ref.read(channelControllerProvider);

    User? user = authView.getCurrentUser();

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
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'Report Channel') {
                _reportChannelDialog(context, widget.channel.id, widget.channel.title, channelController);}
              if (value == 'Leave Channel') {
              _leaveChannelDialog(context, widget.channel.id, user!.uid , channelController);}
            },
            itemBuilder: (context) {
              return [
                const PopupMenuItem(value: 'Report Channel', child: Text('Report Channel')),
                const PopupMenuItem(value: 'Leave Channel', child: Text('Leave Channel')),

              ];
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const CircularProgressIndicator()
                : ChannelPosts(channelId: widget.channel.id, channelName:  widget.channel.title),
          ),
        ],
      ),
    );
  }
}


